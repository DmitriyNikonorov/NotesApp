//
//  MainScreenView.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import UIKit

final class MainScreenView: UIView {
    // MARK: - Properties
    private lazy var collectionView: UICollectionView = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: viewLayout
        )
        collectionView.toAutoLayout()
        return collectionView
    }()
    
    // MARK: - Methods
    private func setupSubviews() {
        addSubviews(collectionView)
    }

    private func setupCollection() {
        collectionView.register(
            NoteCollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionReuseIdentifiers.note.rawValue
        )
        collectionView.register(
            HeaderCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionReuseIdentifiers.header.rawValue)
    }

    private func setupConstraints() {
        [
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ].forEach { $0.isActive = true }
    }

    // MARK: - Init
    init(
        collectionViewDataSource: UICollectionViewDataSource,
        collectionViewDelegate: UICollectionViewDelegateFlowLayout ) {
            super.init(frame: .zero)
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = collectionViewDelegate
            setupSubviews()
            setupCollection()
            setupConstraints()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface
    lazy var addToCollection: (([IndexPath]) -> Void) = { [weak self] indexPath in
        guard let self = self else { return }
        self.collectionView.insertItems(at: indexPath)
    }

    lazy var removeFromCollection: (([IndexPath]) -> Void) = { [weak self] indexPath in
        guard let self = self else { return }
        self.collectionView.deleteItems(at: indexPath)
    }

    lazy var addGesture: ((UILongPressGestureRecognizer) -> Void) = { [weak self] recognizer in
        guard let self = self else { return }
        self.collectionView.addGestureRecognizer(recognizer)
    }

    lazy var getIndexPath: ((CGPoint) -> IndexPath?) = { [weak self] point in
        guard let self = self else { return nil }
        let indexPath = self.collectionView.indexPathForItem(at: point)
        return indexPath
    }

    lazy var getViewForCoordinates: (() -> UICollectionView) = { [weak self] in
        guard let self = self else { return UICollectionView() }
        return self.collectionView
    }

    lazy var setCellStateForNormal: ((Bool, [IndexPath]) -> Void) = { [weak self] istrue, indexPaths in
        guard let self = self else { return }
        for indexPath in indexPaths {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? Selectable else { return }
            cell.changeUI(toNormal: istrue)
        }
    }
}

//MARK: - Extention Setupable
extension MainScreenView: Setupable {
    func setup(withModel model: ModelProtocol) {
        guard let model = model as? MainScreenModel.Model else { return }
        backgroundColor = model.mainBackgroundColor
        collectionView.backgroundColor = model.mainBackgroundColor
    }
}
