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
}

//MARK: - Extention Setupable
extension MainScreenView: Setupable {
    func setup(withModel model: ModelProtocol) {
        guard let model = model as? MainScreenModel.Model else { return }
        backgroundColor = model.mainBackgroundColor
        collectionView.backgroundColor = model.mainBackgroundColor
    }
}
