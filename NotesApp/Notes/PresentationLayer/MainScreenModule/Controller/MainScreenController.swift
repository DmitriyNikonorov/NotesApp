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
    //TODO: - Temporary
    private lazy var titlesArray: [NoteModel] = [
//        NoteModel(text: "Shopping list", lastModifiedDate: "")
    ]

    private lazy var favoriteArray: [NoteModel] = []

    // MARK: - Properties
    enum NotesState {
        case normal
        case edit
    }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "MMM d yyyy, HH:mm"
        return dateFormatter
    }()

    private var notesState: NotesState = .normal
    private lazy var selectedNotesCoorinatesArray: [IndexPath] = []

    private let vibration: Vibrationable
    private var mainModel: MainScreenModel?

    private lazy var mainView: MainScreenView = {
        let moduleView = MainScreenView(collectionViewDataSource: self, collectionViewDelegate: self)
        return moduleView
    }()

    // MARK: - Methods
    private func setupModel(model: ModelProtocol) {
        guard let newModel = model as? MainScreenModel else { return }
        mainModel = newModel
    }

    private func setupMainView(model: MainScreenModel?) {
        guard let model = model else { return }
        view.backgroundColor = model.mainBackgroundColor
        var subModel = model.model
        subModel.noteCount = UInt(titlesArray.count)
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
        notesCountlabel.text = getStringForMiddleToolBarItem(from: mainModel, and: titlesArray)
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

    private func createAndOpenNote(at indexPath: IndexPath, from source: CreationSource) {
        title = nil
        let model = titlesArray[indexPath.row]
//        let currentDate = Date()
//        let currentDateString = dateFormatter.string(from: currentDate)
        var noteScreenModel = NoteScreenModel()
        noteScreenModel.time = model.lastModifiedDate
        noteScreenModel.model.noteText = model.text
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

    //MARK: - Objc methods
    @objc private func deleteButtonDidTapped(_ sender: UIBarButtonItem) {
        guard let mainModel = mainModel else { return }
        let newArray = selectedNotesCoorinatesArray.sorted(by: { $0.row > $1.row })
        newArray.forEach { titlesArray.remove(at: $0.row) }
        mainView.removeFromCollection(selectedNotesCoorinatesArray)
        selectedNotesCoorinatesArray.forEach { addOrRemoveNotesFromSelected(with: $0) }

        ///reload toolbar
        guard let item = toolbarItems?[2] else { return }
        guard let label = item.customView as? UILabel else { return }
        label.text = getStringForMiddleToolBarItem(from: mainModel, and: titlesArray)
        vibration.vibrate(state: .selection)
        toolBarItemsForDeletion(isShow: false)
    }

    @objc private func doneButtonDidTapped(_ sender: UIBarButtonItem) {
        mainView.setCellStateForNormal(true, selectedNotesCoorinatesArray)
        selectedNotesCoorinatesArray.forEach { addOrRemoveNotesFromSelected(with: $0)}
        selectedNotesCoorinatesArray.removeAll()
        toolBarItemsForDeletion(isShow: false)
    }

    @objc private func addButtonDidTapped(_ sender: UIBarButtonItem) {
//        guard let mainModel = mainModel else { return }

        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)


        let newNote = NoteModel(text: NSAttributedString(""), lastModifiedDate: currentDateString)
        titlesArray.append(newNote)
        let indexPath = IndexPath(row: titlesArray.count - 1, section: 1)
        mainView.addToCollection([indexPath])

//        guard let item = toolbarItems?[2] else { return }
//        guard let label = item.customView as? UILabel else { return }
//        label.text = getStringForMiddleToolBarItem(from: mainModel, and: titlesArray)
//        vibration.vibrate(state: .selection)

        createAndOpenNote(at: indexPath, from: .fromMainScreen)
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
    init(vibration: Vibrationable, model: ModelProtocol) {
        self.vibration = vibration
        super.init(model: model)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel(model: model)
        setupView(mainView)
        setupConstraints(ofMainView: mainView)
        setupMainView(model: mainModel)
        setupNavigationBar()
        createToolbar()
        setupGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            return titlesArray.count
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
            cell.loadDataInCell(title: data.text.description.isEmpty ? mainModel.textForEmptyCell : data.text)
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
            let noteModel = titlesArray[indexPath.row]
            cell.loadDataInCell(title: noteModel.text.description.isEmpty ? mainModel.textForEmptyCell : noteModel.text)

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
            createAndOpenNote(at: indexPath, from: .fromMainScreen)
        }
    }
}

//MARK: - Extention UICollectionViewDelegateFlowLayout
extension MainScreenController: UICollectionViewDelegateFlowLayout {
    private func itemWidth(for width: CGFloat, spacing: CGFloat) -> CGFloat {
        let itemsInRow: CGFloat = 3
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
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        let newNote = NoteModel(text: NSAttributedString(""), lastModifiedDate: currentDateString)
        titlesArray.append(newNote)
        let indexPath = IndexPath(row: titlesArray.count - 1, section: 1)
        mainView.addToCollection([indexPath])
        createAndOpenNote(at: indexPath, from: .fromNote)

//        let currentDate = Date()
//        let currentDateString = dateFormatter.string(from: currentDate)
//        var noteScreenModel = NoteScreenModel()
//        noteScreenModel.time = currentDateString
//        let noteScreenController = NoteScreenController(
//            creatableDelegaet: self,
//            model: noteScreenModel,
//            source: .fromNote
//        )
//        let newNavigationController = UINavigationController(rootViewController: noteScreenController)
//        newNavigationController.modalPresentationStyle = .fullScreen
//        present(newNavigationController, animated: true)


        

        //        navigationController?.pushViewController(noteScreenController, animated: false)
//        guard let item = toolbarItems?[2] else { return }
//        guard let label = item.customView as? UILabel else { return }
//        label.text = getStringForMiddleToolBarItem(from: mainModel, and: titlesArray)
//        vibration.vibrate(state: .selection)
    }

    func getNewTime() -> String {
        let currentDate = Date()
        let currentDateString = dateFormatter.string(from: currentDate)
        return currentDateString
    }
}
