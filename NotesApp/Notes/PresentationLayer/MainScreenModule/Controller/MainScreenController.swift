//
//  MainScreenController.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit
import AVFoundation

final class MainScreenController: BasicViewController {
    // MARK: - Properties
    private lazy var notesModelArray: [NoteModel] = []
    private lazy var favoriteArray: [NoteModel] = []

    private lazy var itemsInRow: CGFloat = 3

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "MMM d yyyy, HH:mm"
        return dateFormatter
    }()

    enum NotesState {
        case normal
        case edit
    }

    private var notesState: NotesState = .normal
    private lazy var selectedNotesCoorinatesArray: [IndexPath] = []

    private let vibration: Vibrationable
    private var mainModel: MainScreenModel?
    private let databaseCoordinator: DatabaseCoordinatable

    private lazy var mainView: MainScreenView = {
        let moduleView = MainScreenView(collectionViewDataSource: self, collectionViewDelegate: self)
        return moduleView
    }()

    // MARK: - Methods
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        setNumberOfItemsFromOrientation()
    }

    private func setupModel(model: ModelProtocol) {
        guard let newModel = model as? MainScreenModel else { return }
        mainModel = newModel
    }

    private func setupMainView(model: MainScreenModel?) {
        guard let model = model else { return }
        view.backgroundColor = model.mainBackgroundColor
        var subModel = model.model
        subModel.noteCount = UInt(notesModelArray.count)
        mainView.setup(withModel: subModel)
    }

    private func getStringForMiddleToolBarItem(
        from model: MainScreenModel,
        and notesArray: [NoteModel]
    ) -> String {
        let space = "   "
        let count = notesArray.count
        let named = model.noteCountLabelText

        if count == 1 {
            let newNamed = named.dropLast()
            let text = space + String(count) + " " + newNamed + space
            return text
        } else {
            let text = space + String(count) + " " + named + space
            return text
        }
    }

    private func setupNavigationBar() {
        guard let mainModel = mainModel else { return }
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.backgroundColor = mainModel.mainBackgroundColor
        scrollAppearance.titleTextAttributes = [.foregroundColor: mainModel.mainTitleColor]
        scrollAppearance.largeTitleTextAttributes = [.foregroundColor: mainModel.mainTitleColor]

        let standartAppearance = UINavigationBarAppearance()
        standartAppearance.largeTitleTextAttributes = [.foregroundColor: mainModel.mainTitleColor]
        standartAppearance.titleTextAttributes = [.foregroundColor : mainModel.mainTitleColor]
        standartAppearance.backgroundColor = mainModel.noteBackground

        navigationController?.navigationBar.scrollEdgeAppearance = scrollAppearance
        navigationController?.navigationBar.standardAppearance = standartAppearance
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: mainModel.settingButtonImage,
            style: .plain,
            target: self,
            action: #selector(addButtonDidTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = mainModel.settingButtonImageColor
        title = mainModel.mainTitle
        navigationController?.navigationBar.barTintColor = .black
    }

    private func createToolbar(){
        guard let mainModel = mainModel else { return }
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = mainModel.noteBackground
        navigationController?.toolbar.standardAppearance = appearance
        navigationController?.toolbar.scrollEdgeAppearance = appearance

        var buttons = [UIBarButtonItem]()
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil))
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        //title
        let notesCountlabel = UILabel()
        notesCountlabel.text = getStringForMiddleToolBarItem(from: mainModel, and: notesModelArray)
        notesCountlabel.font = mainModel.noteCountLabelFont
        buttons.append(UIBarButtonItem(customView: notesCountlabel))
        //indent
        buttons.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        //button
        let addButon = UIBarButtonItem(
            image: mainModel.addButtonImage,
            style: .plain,
            target: self,
            action: #selector(addButtonDidTapped)
        )
        addButon.tintColor = mainModel.addButtonImageColor
        buttons.append(addButon)

        toolbarItems = buttons
        navigationController?.setToolbarHidden(false, animated: false)
    }

    private func setupGestureRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPress)
        )
        mainView.addGesture(longPressRecognizer)
    }

    private func changeState(state: NotesState) {
        switch state {
        case .normal:
            self.notesState = .edit
        case .edit:
            self.notesState = .normal
        }
    }

    private func addOrRemoveNotesFromSelected(with indexPath: IndexPath) {
        if selectedNotesCoorinatesArray.contains(indexPath) {
            selectedNotesCoorinatesArray.removeAll(where: { $0 == indexPath})
            guard selectedNotesCoorinatesArray.isEmpty else { return }
            changeState(state: notesState)
            toolBarItemsForDeletion(isShow: false)
        } else {
            selectedNotesCoorinatesArray.append(indexPath)
        }
    }

    ///Item display logic for deleting cells
    private func toolBarItemsForDeletion(isShow: Bool) {
        guard let mainModel = mainModel else { return }
        if isShow {
            let deleteButton = UIBarButtonItem(
                image: UIImage(systemName: "trash"),
                style: .plain,
                target: self,
                action: #selector(deleteButtonDidTapped)
            )
            let doneButton = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(doneButtonDidTapped)
            )
            deleteButton.tintColor = Palette.systemElement.color
            doneButton.tintColor = Palette.systemElement.color
            toolbarItems?[0] = (deleteButton)
            toolbarItems?[4] = (doneButton)
        } else {
            let firstIndent = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
            let addButon = UIBarButtonItem(
                image: mainModel.addButtonImage,
                style: .plain,
                target: self,
                action: #selector(addButtonDidTapped)
            )
            addButon.tintColor = mainModel.addButtonImageColor

            toolbarItems?[0] = (firstIndent)
            toolbarItems?[4] = (addButon)
        }
    }

    private func reloadToolBar(withModel mainModel: MainScreenModel?) {
        guard let model = mainModel else { return }
        guard let item = toolbarItems?[2] else { return }
        guard let label = item.customView as? UILabel else { return }
        label.text = getStringForMiddleToolBarItem(from: model, and: notesModelArray)
        toolBarItemsForDeletion(isShow: false)
    }

    private func openNote(at indexPath: IndexPath, from source: CreationSource) {
        title = nil
        let model = notesModelArray[indexPath.row]
        let currentDateString = dateFormatter.string(from: model.lastModifiedDate)

        var noteScreenModel = NoteScreenModel()
        noteScreenModel.time = currentDateString
        noteScreenModel.model.noteText = model.textInAttributedString
        noteScreenModel.index = indexPath.row

        if source == .fromMainScreen {
            let noteScreenController = NoteScreenController(
                creatableDelegaet: self,
                model: noteScreenModel,
                source: .fromMainScreen
            )
            navigationController?.pushViewController(noteScreenController, animated: true)
        } else {
            let noteScreenController = NoteScreenController(
                creatableDelegaet: self,
                model: noteScreenModel,
                source: .fromNote
            )
            let newNavigationController = UINavigationController(rootViewController: noteScreenController)
            newNavigationController.modalPresentationStyle = .fullScreen
            present(newNavigationController, animated: true)
        }
    }

    private func createNoteModelAndSaveInDataBase(from source: CreationSource) {
        var index = 0
        if notesModelArray.count > 0 {
            index = notesModelArray.count
        }
        let currentDate = Date()
        let newNote = NoteModel(
            textInAttributedString: NSAttributedString(),
            lastModifiedDate: currentDate,
            index: index
        )

        databaseCoordinator.create(NoteDataModel.self, keyedValues: newNote.keyedValues) {
            [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.notesModelArray.append(newNote)
                let indexPath = IndexPath(row: self.notesModelArray.count - 1, section: 1)
                self.mainView.addToCollection([indexPath])
                self.openNote(at: indexPath, from: source)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }

    private func deleteNotesFromDataBase(at index: Int) {
        let predicate = NSPredicate(format: "index == %@", String(index))
        databaseCoordinator.delete(NoteDataModel.self, predicate: predicate) { result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }

    private func fetchAllNotesFromDataBase() {
        databaseCoordinator.fetchAll(NoteDataModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let dataModelsArray):
                let notesModelArray = dataModelsArray.map {
                    NoteModel(noteDataModel: $0)
                }

                var newNotesArray: [NoteModel] = []
                notesModelArray.forEach {
                    if let model = $0 {
                        newNotesArray.append(model)
                    }
                }
                newNotesArray.forEach { self.notesModelArray.append($0) }
                self.setupView(self.mainView)
                self.setupConstraints(ofMainView: self.mainView)
                self.reloadToolBar(withModel: self.mainModel)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }

    private func setNumberOfItemsFromOrientation() {
        if UIDevice.current.orientation.isLandscape {
            itemsInRow = 5
        } else if UIDevice.current.orientation.isPortrait {
            itemsInRow = 3
        }
    }

    //MARK: - Objc methods
    @objc private func deleteButtonDidTapped(_ sender: UIBarButtonItem) {
        guard let mainModel = mainModel else { return }
        let newArray = selectedNotesCoorinatesArray.sorted(by: { $0.row > $1.row })
        newArray.forEach {
            notesModelArray.remove(at: $0.row)
            deleteNotesFromDataBase(at: $0.row)
        }
        mainView.removeFromCollection(selectedNotesCoorinatesArray)
        selectedNotesCoorinatesArray.forEach { addOrRemoveNotesFromSelected(with: $0) }
        vibration.vibrate(state: .heavy)
        reloadToolBar(withModel: mainModel)
    }

    @objc private func doneButtonDidTapped(_ sender: UIBarButtonItem) {
        mainView.setCellStateForNormal(true, selectedNotesCoorinatesArray)
        selectedNotesCoorinatesArray.forEach { addOrRemoveNotesFromSelected(with: $0)}
        selectedNotesCoorinatesArray.removeAll()
        toolBarItemsForDeletion(isShow: false)
    }

    @objc private func addButtonDidTapped(_ sender: UIBarButtonItem) {
        createNoteModelAndSaveInDataBase(from: .fromMainScreen)
    }

    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let collectionView = mainView.getViewForCoordinates()
            let touchPoint = longPressGestureRecognizer.location(in: collectionView)
            let itemIndexpath = mainView.getIndexPath(touchPoint)
            if let indexPath = itemIndexpath {
                toolBarItemsForDeletion(isShow: true)
                notesState = .edit
                vibration.vibrate(state: .medium)
                addOrRemoveNotesFromSelected(with: indexPath)
                mainView.setCellStateForNormal(false, [indexPath])
            }
        }
    }

    // MARK: - Init
    init(vibration: Vibrationable, model: ModelProtocol, databaseCoordinator: DatabaseCoordinatable) {
        self.vibration = vibration
        self.databaseCoordinator = databaseCoordinator
        super.init(model: model)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel(model: model)
        fetchAllNotesFromDataBase()
        setupMainView(model: mainModel)
        setupNavigationBar()
        createToolbar()
        setupGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNumberOfItemsFromOrientation()
        setupNavigationBar()
        createToolbar()
    }
}

//MARK: - Extention UICollectionViewDataSource
extension MainScreenController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if section == 0 {
            return favoriteArray.count
        } else {
            return notesModelArray.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let mainModel = mainModel else {
            return UICollectionViewCell(frame: .zero)
        }
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionReuseIdentifiers.note.rawValue,
                for: indexPath
            ) as? NoteCollectionViewCell else {
                return UICollectionViewCell(frame: .zero)
            }

            let cellModel = CellModel(
                titleLabelFont: mainModel.cellTitleLabelFont,
                titleLabelTextColor: mainModel.cellTitlelabelTextColor,
                normalBackgroundColor: mainModel.cellNormalBackgroundColor,
                selectedBackgroundColor: mainModel.cellSelectedBackgroundColor
            )

            cell.setupCell(with: cellModel)
            let data = favoriteArray[indexPath.row]
            cell.loadDataInCell(title: data.textInAttributedString.description.isEmpty ? mainModel.textForEmptyCell : data.textInAttributedString)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CollectionReuseIdentifiers.note.rawValue,
                for: indexPath
            ) as? NoteCollectionViewCell else {
                return UICollectionViewCell(frame: .zero)
            }

            let cellModel = CellModel(
                titleLabelFont: mainModel.cellTitleLabelFont,
                titleLabelTextColor: mainModel.cellTitlelabelTextColor,
                normalBackgroundColor: mainModel.cellNormalBackgroundColor,
                selectedBackgroundColor: mainModel.cellSelectedBackgroundColor
            )
            cell.setupCell(with: cellModel)
            let noteModel = notesModelArray[indexPath.row]
            cell.loadDataInCell(title: noteModel.textInAttributedString.description.isEmpty ? mainModel.textForEmptyCell : noteModel.textInAttributedString)

            if selectedNotesCoorinatesArray.contains(indexPath) {
                cell.changeUI(toNormal: false)
            } else {
                cell.changeUI(toNormal: true)
            }
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let mainModel = mainModel else {
            return UICollectionReusableView(frame: .zero)
        }
        switch indexPath.section {
        case 0:
            if favoriteArray.isEmpty {
                return UICollectionReusableView(frame: .zero)
            } else {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: CollectionReuseIdentifiers.header.rawValue,
                    for: indexPath
                ) as? HeaderCollectionView else {
                    return UICollectionReusableView(frame: .zero)
                }
                header.setup(with: mainModel.fixedHeaderText, andFont: mainModel.fixedHeaderFont)
                return header
            }
        default:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: CollectionReuseIdentifiers.header.rawValue,
                for: indexPath
            ) as? HeaderCollectionView else {
                return UICollectionReusableView(frame: .zero)
            }
            header.setup(with: mainModel.allHeaderText, andFont: mainModel.allHeaderFont)
            return header
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            if favoriteArray.isEmpty {
                return CGSize(width: 0, height: 0)
            } else {
                return CGSize(width: view.frame.width, height: 40.0)
            }
        default:
            return CGSize(width: view.frame.width, height: 40.0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch notesState {
        case .edit:
            if selectedNotesCoorinatesArray.contains(indexPath) {
                addOrRemoveNotesFromSelected(with: indexPath)
                mainView.setCellStateForNormal(true, [indexPath])
                vibration.vibrate(state: .medium)
            } else {
                addOrRemoveNotesFromSelected(with: indexPath)
                mainView.setCellStateForNormal(false, [indexPath])
                vibration.vibrate(state: .medium)
            }
        case .normal:
            openNote(at: indexPath, from: .fromMainScreen)
        }
    }
}

//MARK: - Extention UICollectionViewDelegateFlowLayout
extension MainScreenController: UICollectionViewDelegateFlowLayout {
    private func itemWidth(for width: CGFloat, spacing: CGFloat) -> CGFloat {
        let totalSpacing: CGFloat = itemsInRow * spacing + itemsInRow * spacing
        let finalWidth = (width - totalSpacing) / itemsInRow
        return floor(finalWidth)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = itemWidth(for: view.frame.width, spacing: Constants.spacing)
        return CGSize(width: width, height: Constants.itemHeight)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
            return UIEdgeInsets(
                top: Constants.insets,
                left: Constants.insets,
                bottom: Constants.insets,
                right: Constants.insets
            )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.spacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        Constants.insets
    }
}

//MARK: - Extention Creatable
extension MainScreenController: Creatable {
    func createNewNote() {
        createNoteModelAndSaveInDataBase(from: .fromNote)
    }

    func getNewTime() -> String {
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        return currentDateString
    }

    func saveChanges(withString string: NSAttributedString, and index: Int) {
        let predicate = NSPredicate(format: "index == %@", String(index))

        var stringData = Data()
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: string,
                requiringSecureCoding: false
            )
            stringData = data
        } catch {
            debugPrint("error encoding")
        }
        
        let date = Date()
        let keyedValues: [String: Any] = ["text": stringData, "date": date]
        databaseCoordinator.update(
            NoteDataModel.self,
            predicate: predicate,
            keyedValues: keyedValues
        ) {
            [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let dataModelsArray):
                let notesModelArray = dataModelsArray.map {
                    NoteModel(noteDataModel: $0)
                }

                var newNotesArray: [NoteModel] = []
                notesModelArray.forEach {
                    if let model = $0 {
                        newNotesArray.append(model)
                    }
                }
                newNotesArray.forEach {
                    self.notesModelArray[$0.index] = $0
                }
                let indexPath = IndexPath(item: newNotesArray[0].index, section: 1)
                self.mainView.reloadItem([indexPath])
            case .failure(let error):
                print(error)
            }
        }
    }
}
