//
//  BasicViewController.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import UIKit

class BasicViewController: UIViewController {
    // MARK: - Properties
    ///Model of this module
    var model: ModelProtocol

    // MARK: - Methods
    func setupView(_ mainView: UIView) {
        mainView.toAutoLayout()
        view.addSubview(mainView)
    }

    func setupConstraints(ofMainView mainView: UIView) {
        [
            mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ].forEach { $0.isActive = true }
    }

    // MARK: - Init
    init(model: ModelProtocol) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
