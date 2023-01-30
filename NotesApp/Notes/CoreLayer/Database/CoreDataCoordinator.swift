//
//  CoreDataCoordinator.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 30.01.2023.
//

import Foundation
import CoreData


enum Extensions: String {
    case momd
}

enum DatabaseName: String {
    case database = "Database"
}

private enum CompletionHandlerType {
    case success
    case failure(error: DatabaseError)
}

final class CoreDataCoordinator {

    let modelName: String
    private let model: NSManagedObjectModel
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator

    private lazy var saveContext: NSManagedObjectContext = {
        let saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        saveContext.parent = self.mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        return saveContext
    }()

    private lazy var mainContext: NSManagedObjectContext = {
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        return mainContext
    }()

    private lazy var masterContext: NSManagedObjectContext = {
        let masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        masterContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        return masterContext
    }()

    init(nameOfDataModelResource resource: String, withExtension name: Extensions) throws {

        let bundle = Bundle.main
        guard let url = bundle.url(forResource: resource, withExtension: name.rawValue) else {
            fatalError("Can't find Database.xcdatamodeld in main Bundle")
        }

        let pathExtention = url.pathExtension
        guard let name = try? url.lastPathComponent.replace(pathExtention, replacement: "") else {
            throw DatabaseError.error(description: "")
        }

        /// Создаем модель NSManagedObjectModel на основе DataModel модели по URL
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            throw DatabaseError.error(description: "Unable to create NSManagedObjectModel based on Data Model")
        }

        self.modelName = name //Database

        self.model = model
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        setup()
    }

    private func setup() {
        let fileManager = FileManager.default
        let storeName = "\(modelName)" + "sqlite" //Database.sqlite
        ///Create a URL to the documentDirectory
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        ///Create a path for our database
        let persistentStoreURL = documentsDirectoryURL?.appendingPathComponent(storeName)

        do {
            ///Создаем опции
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]

            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreURL,
                options: options
            )
        } catch {
            let _: DatabaseError = .store(model: modelName)
        }
    }

    private func handler(
        for type: CompletionHandlerType,
        using context: NSManagedObjectContext,
        contextWorkInOwnQueue: Bool = true,
        with completionHandler: (() -> Void)?,
        and failureCompletion: ((DatabaseError) -> Void)?
    ) {
        switch type {
        case .success:
            if context.concurrencyType == .mainQueueConcurrencyType {
                if contextWorkInOwnQueue {
                    completionHandler?()
                } else {
                    self.mainContext.perform {
                        completionHandler?()
                    }
                }
            }
        case .failure(let error):
            if context.concurrencyType == .privateQueueConcurrencyType {
                if context.parent != nil {
                    self.mainContext.perform {
                        failureCompletion?(error)
                    }
                }
            } else {
                if contextWorkInOwnQueue {
                    failureCompletion?(error)
                } else {
                    failureCompletion?(error)
                }
            }
        }
    }

    private func save(
        with context: NSManagedObjectContext,
        completionHandler: (() -> Void)? = nil,
        failureCompletion: ((DatabaseError) -> Void)? = nil
    ) {
        guard context.hasChanges else {
            if context.parent != nil {
                self.handler(
                    for: .failure(error: .error(description: "☀️Context has not change!")),
                    using: context,
                    contextWorkInOwnQueue: false,
                    with: completionHandler,
                    and: failureCompletion
                )
            }
            return
        }

        context.perform {
            do {
                try context.save()
            } catch _ {
                if context.parent != nil {
                    self.handler(
                        for: .failure(error: .error(description: "Unable to save changes of context.")),
                        using: context,
                        with: completionHandler,
                        and: failureCompletion
                    )
                }
            }
            guard let parentContext = context.parent else { return }
            self.handler(for: .success, using: context, with: completionHandler, and: failureCompletion)
            self.save(with: parentContext, completionHandler: completionHandler, failureCompletion: failureCompletion)
        }
    }
}


extension CoreDataCoordinator: DatabaseCoordinatable {
    func create<T: Storable>(_ model: T.Type, keyedValues: [String: Any], completion: @escaping (Result<T, DatabaseError>) -> Void)  {
        self.saveContext.perform { [weak self] in
            guard let self = self else { return }

                guard let entityDescription = NSEntityDescription.entity(
                    forEntityName: String(describing: model),
                    in: self.saveContext
                )
                else {
                    completion(.failure(.wrongModel))
                    return
                }
                let entity = NSManagedObject(entity: entityDescription, insertInto: self.saveContext)
                entity.setValuesForKeys(keyedValues)

            guard let objects = entity as? T else {
                completion(.failure(.wrongModel))
                return
            }

            guard self.saveContext.hasChanges else {
                completion(.failure(.store(model: String(describing: model.self))))
                return
            }

            self.save(with: self.saveContext,
                      completionHandler: {
                completion(.success(objects))
            },
                      failureCompletion: { error in
                completion(.failure(error))
            })
        }
    }

    func update<T>(_ model: T.Type, predicate: NSPredicate?, keyedValues: [String: Any], completion: @escaping (Result<[T], DatabaseError>) -> Void) where T : Storable {
        self.fetch(model, predicate: predicate) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let fetchedObjects):
                guard let fetchedObjects = fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else {
                    completion(.failure(.wrongModel))
                    return
                }

                self.saveContext.perform {
                    fetchedObjects.forEach { fetchedObject in
                        fetchedObject.setValuesForKeys(keyedValues)
                    }

                    let castFetchedObjects = fetchedObjects as? [T] ?? []

                    self.save(with: self.saveContext,
                              completionHandler: {
                        completion(.success(castFetchedObjects))
                    },
                              failureCompletion: { error in
                        completion(.failure(error))
                    })
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }



    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate?, completion: @escaping (Result<[T], DatabaseError>) -> Void) {
        guard let model = model as? NSManagedObject.Type else {
            completion(.failure(.wrongModel))
            return
        }

        self.saveContext.perform {
            let request = model.fetchRequest()
            request.predicate = predicate
            guard
                let fetchRequestResult = try? self.saveContext.fetch(request),
                let fetchedObjects = fetchRequestResult as? [T]
            else {
                self.mainContext.perform {
                    completion(.failure(.wrongModel))
                }
                return
            }

            self.mainContext.perform {
                completion(.success(fetchedObjects))
            }
        }
    }

    func fetchAll<T>(_ model: T.Type, completion: @escaping (Result<[T], DatabaseError>) -> Void) where T : Storable {
        self.fetch(model, predicate: nil, completion: completion)
    }

    func delete<T>(_ model: T.Type, predicate: NSPredicate?, completion: @escaping (Result<[T], DatabaseError>) -> Void) where T : Storable {
        self.fetch(model, predicate: predicate) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let fetchedObjects):
                guard let fetchedObjects = fetchedObjects as? [NSManagedObject], !fetchedObjects.isEmpty else {
                    completion(.failure(.wrongModel))
                    return
                }

                self.saveContext.perform {
                    fetchedObjects.forEach { fetchedObject in
                        self.saveContext.delete(fetchedObject)
                    }
                    let deletedObjects = fetchedObjects as? [T] ?? []

                    self.save(with: self.saveContext,
                              completionHandler: {
                        completion(.success(deletedObjects))
                    },
                              failureCompletion: { error in
                        completion(.failure(error))
                    })
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteAll<T>(_ model: T.Type, completion: @escaping (Result<[T], DatabaseError>) -> Void) where T : Storable {
        self.delete(model, predicate: nil, completion: completion)
    }
}
