//
//  MainScreenController.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import UIKit

final class MainScreenController: UIViewController {
    //TODO: - Temporary
    private lazy var titlesArray: [String] = [
        "", "Shopping list", "to do", "work", "Home", "","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""
    ]

    private lazy var favoriteArray: [String] = ["Shopping"]

    // MARK: - Properties
    private var mainModel: MainScreenModel
    private lazy var moduleView: MainScreenView = {
        let moduleView = MainScreenView(collectionViewDataSource: self, collectionViewDelegate: self)
        moduleView.toAutoLayout()
        return moduleView
    }()

    // MARK: - Methods
    private func setupModuleView(model: MainScreenModel) {
        view.addSubview(moduleView)
        var model = model.model
        model.noteCount = UInt(titlesArray.count)
        moduleView.setup(withModel: model)
        setupConstraints()
    }

    private func setupConstraints() {
        [
            moduleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            moduleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            moduleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            moduleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].forEach { $0.isActive = true }
    }

    private func setupNavigationBar() {
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
        
        title = mainModel.mainTitle
        view.backgroundColor = mainModel.noteBackground
    }

    private func createToolbar(){
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = mainModel.noteBackground
        navigationController?.toolbar.standardAppearance = appearance
        navigationController?.toolbar.scrollEdgeAppearance = appearance

        var buttons = [UIBarButtonItem]()
        //indent
        buttons.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        //title
        let notesCountlabel = UILabel()
        let count = titlesArray.count
        notesCountlabel.text = "\(count)" + " " + mainModel.noteCountLabelText
        notesCountlabel.font = mainModel.noteCountLabelFont
        buttons.append(UIBarButtonItem(customView: notesCountlabel))
        //indent
        buttons.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        //button
        let tintedImage = mainModel.addButtonImage.withRenderingMode(.alwaysTemplate)
        let addButon = UIBarButtonItem(
            image: tintedImage,
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        addButon.tintColor = mainModel.addButtonImageColor
        buttons.append(addButon)

        toolbarItems = buttons
        navigationController?.setToolbarHidden(false, animated: false)
    }

    @objc private func addTapped() {
        print("add tapped")

    }

    // MARK: - Lifecyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModuleView(model: mainModel)
        setupNavigationBar()
        createToolbar()

    }

    // MARK: - Init
    init(model: MainScreenModel) {
        self.mainModel = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}


//MARK: - Extention
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
                backgroundColor: mainModel.cellBackgroundColor
            )

            cell.setupCell(with: cellModel)
            let data = favoriteArray[indexPath.row]
            cell.loadDataInCell(title: data.isEmpty ? mainModel.textForEmptyCell : data)
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
                backgroundColor: mainModel.cellBackgroundColor
            )

            cell.setupCell(with: cellModel)
            let data = titlesArray[indexPath.row]
            cell.loadDataInCell(title: data.isEmpty ? mainModel.textForEmptyCell : data)
            return cell
        }

    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if indexPath.section == 0 {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: CollectionReuseIdentifiers.header.rawValue,
                for: indexPath
            ) as? HeaderCollectionView else {
                return UICollectionReusableView(frame: .zero)
            }
            header.setup(with: mainModel.fixedHeaderText, andFont: mainModel.fixedHeaderFont)
            return header
        } else {
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
        return CGSize(width: view.frame.width, height: 40.0)
    }
}


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
