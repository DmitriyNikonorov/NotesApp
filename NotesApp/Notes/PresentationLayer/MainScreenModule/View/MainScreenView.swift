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

    private lazy var bottomView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        return view
    }()

    // MARK: - Methods
    private func setupUI() {
        addSubviews(collectionView, bottomView)
    }

    private func setupCollection() {
        collectionView.register(
            NoteCollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionReuseIdentifiers.note.rawValue
        )
    }

    private func setupConstraints() {
        [
            bottomView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 30.0),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        ].forEach { $0.isActive = true }
    }

    // MARK: - Init
    init(
        collectionViewDataSource: UICollectionViewDataSource,
        collectionViewDelegate: UICollectionViewDelegateFlowLayout ) {
            super.init(frame: .zero)
            collectionView.dataSource = collectionViewDataSource
            collectionView.delegate = collectionViewDelegate
            setupUI()
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
        bottomView.backgroundColor = model.noteBackground
    }
}
