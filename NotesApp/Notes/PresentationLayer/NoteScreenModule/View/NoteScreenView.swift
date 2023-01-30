//
//  NoteScreenView.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 27.01.2023.
//

import Foundation
import UIKit

final class NoteScreenView: UIView {
    // MARK: - Properties
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.autocorrectionType = .no
        textView.toAutoLayout()
        return textView
    }()

    private lazy var regularAttributes: [NSAttributedString.Key : Any] = [:]
    private lazy var italicAttributes: [NSAttributedString.Key : Any] = [:]
    private lazy var boldAttributes: [NSAttributedString.Key : Any] = [:]


    // MARK: - Methods
    private func setupSubviews() {
        addSubviews(textView)
    }

    private func setupConstraints() {
        [
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ].forEach { $0.isActive = true }
    }

    //MARK: - Objc methods
    @objc private func fontButtonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            changeTextAttributes?(0)
            let string = textView.textStorage.string
            let attributedString = NSAttributedString(string: string, attributes: regularAttributes)
            textView.attributedText = attributedString
        case 1:
            changeTextAttributes?(1)
            let string = textView.textStorage.string
            let attributedString = NSAttributedString(string: string, attributes: italicAttributes)
            textView.attributedText = attributedString
        case 2:
            changeTextAttributes?(2)
            let string = textView.textStorage.string
            let attributedString = NSAttributedString(string: string, attributes: boldAttributes)
            textView.attributedText = attributedString
        default:
            break
        }
    }

    // MARK: - Init
    init(textViewDelegate: UITextViewDelegate) {
        super.init(frame: .zero)
        textView.delegate = textViewDelegate
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Interface
    lazy var actionAfterKeyboardNotification: ((UIEdgeInsets) -> Void) = { [weak self] insets in
        guard let self = self else { return }
        self.textView.contentInset = insets
        self.textView.scrollRangeToVisible(self.textView.selectedRange)
    }

    lazy var hideKeyboard: (() -> Void) = { [weak self] in
        guard let self = self else { return }
        self.textView.resignFirstResponder()
    }

    lazy var getText: (() -> NSAttributedString) = { [weak self] in
        guard let self = self else { return NSAttributedString() }
        return self.textView.attributedText
    }

    var changeTextAttributes: ((Int) -> Void)?
}

extension NoteScreenView: Setupable {
    func setup(withModel model: ModelProtocol) {
        guard let model = model as? NoteScreenModel.Model else { return }
        textView.attributedText = model.noteText

        regularAttributes = model.regularButtonAttributes
        italicAttributes = model.italicButtonAttributes
        boldAttributes = model.boldButtonAttributes

        let bar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        var buttons = [UIBarButtonItem]()
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))

        //button
        let boldButton = UIButton(type: .system)
        let boldAttributedString = NSAttributedString(
            string: model.boldButtonText,
            attributes: model.boldButtonAttributes
        )
        boldButton.setAttributedTitle(boldAttributedString, for: .normal)
        boldButton.addTarget(self, action: #selector(fontButtonTapped), for: .touchUpInside)
        boldButton.tag = 2
        let boldBarButton = UIBarButtonItem(customView: boldButton)
        buttons.append(boldBarButton)
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))

        //button
        let italicButton = UIButton(type: .system)
        let italicAttributedString = NSAttributedString(
            string: model.italicButtonText,
            attributes: model.italicButtonAttributes
        )
        italicButton.setAttributedTitle(italicAttributedString, for: .normal)
        italicButton.addTarget(self, action: #selector(fontButtonTapped), for: .touchUpInside)
        italicButton.tag = 1
        let italicBarButton = UIBarButtonItem(customView: italicButton)
        buttons.append(italicBarButton)
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))

        //button
        let regularButton = UIButton(type: .system)
        let regularAttributedString = NSAttributedString(
            string: model.regularButtonText,
            attributes: model.regularButtonAttributes
        )
        regularButton.setAttributedTitle(regularAttributedString, for: .normal)
        regularButton.addTarget(self, action: #selector(fontButtonTapped), for: .touchUpInside)
        regularButton.tag = 0
        let regularBarButton = UIBarButtonItem(customView: regularButton)
        buttons.append(regularBarButton)
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))

        bar.items = buttons
        bar.sizeToFit()
        textView.inputAccessoryView = bar
    }
}
