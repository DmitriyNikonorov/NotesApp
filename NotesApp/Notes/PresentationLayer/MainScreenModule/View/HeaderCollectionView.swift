//
//  HeaderCollectionView.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import UIKit

final class HeaderCollectionView: UICollectionReusableView {
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.toAutoLayout()
        return titleLabel
    }()

    // MARK: - Methods
    private func setupConstraints() {
        [
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ].forEach { $0.isActive = true }
    }

    // MARK: - Interface
    func setup(with title: String, andFont font: UIFont) {
        addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.font = font
        setupConstraints()
    }
}
