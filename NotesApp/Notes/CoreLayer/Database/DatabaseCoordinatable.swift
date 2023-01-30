//
//  DatabaseCoordinatable.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 30.01.2023.
//

import Foundation
import CoreData

enum DatabaseError: Error {
/// Unable to add storage
    case store(model: String)
/// momd file not found
    case find(model: String, bundle: Bundle?)
/// Object model not found
    case wrongModel
/// Custom error
    case error(description: String)
/// Unknown error
    case unknown(error: Error)
}

protocol DatabaseCoordinatable {
    func create<T: Storable>(_ model: T.Type, keyedValues: [String: Any], completion: @escaping (Result<T, DatabaseError>) -> Void)

    func delete<T: Storable>(_ model: T.Type, predicate: NSPredicate?, completion: @escaping (Result<[T], DatabaseError>) -> Void)

    func deleteAll<T: Storable>(_ model: T.Type, completion: @escaping (Result<[T], DatabaseError>) -> Void)

    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate?, completion: @escaping (Result<[T], DatabaseError>) -> Void)

    func fetchAll<T: Storable>(_ model: T.Type, completion: @escaping (Result<[T], DatabaseError>) -> Void)

    func update<T: Storable>(_ model: T.Type, predicate: NSPredicate?, keyedValues: [String: Any], completion: @escaping (Result<[T], DatabaseError>) -> Void)
}

