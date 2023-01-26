//
//  NoteCollectionViewCell.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import UIKit

final class NoteCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.toAutoLayout()
        return titleLabel
    }()


    // MARK: - Methods
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.layer.cornerRadius = 10
    }

    private func setupConstraints() {
        [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
            titleLabel.trailingAnchor.constraint(equalTo:contentView.trailingAnchor, constant: -8.0),
        ].forEach { $0.isActive = true }
    }


    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface
    func setupCell(with cellModel: CellModel) {
        titleLabel.font = cellModel.titleLabelFont
        titleLabel.textColor = cellModel.titleLabelTextColor
        contentView.backgroundColor = cellModel.backgroundColor
    }


    func loadDataInCell(title: String) {
        titleLabel.text = title
    }
}
