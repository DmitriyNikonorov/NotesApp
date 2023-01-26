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
        "", "Shopping list", "to do", "work", "Home"
    ]
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
        moduleView.setup(withModel: model.model)
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

    // MARK: - Lifecyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModuleView(model: mainModel)
        setupNavigationBar()

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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titlesArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
