//
//  NoteScreenView.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 27.01.2023.
//

import UIKit

final class NoteScreenView: UIView {
    // MARK: - Properties
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.autocorrectionType = .no
        textView.toAutoLayout()
        return textView
    }()


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

    private func addToolBar() {
        let bar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        var buttons = [UIBarButtonItem]()


        buttons.append(UIBarButtonItem(title: "Test", style: .plain, target: self, action: #selector(H1ButtonTapped)))

        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        //button
        let boldButton = UIButton(type: .system)
        let attributedString = NSAttributedString(string: "Bold", attributes: [.font: FontKit.bold.font, .foregroundColor: Palette.mainText.color])
        boldButton.setAttributedTitle(attributedString, for: .normal)
        boldButton.addTarget(self, action: #selector(fontButtonTapped), for: .touchUpInside)
        boldButton.tag = 2
        let boldBarButton = UIBarButtonItem(customView: boldButton)
        buttons.append(boldBarButton)
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        //button
        let italicButton = UIButton(type: .system)
        let italicAttributedString = NSAttributedString(
            string: "Italic",
            attributes: [.font: FontKit.italic.font, .foregroundColor: Palette.mainText.color]
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
            string: "Regular",
            attributes: [.font: FontKit.regular.font, .foregroundColor: Palette.mainText.color]
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

    private var mutStr = NSMutableAttributedString()

    //MARK: - Objc methods
    @objc private func fontButtonTapped(_ sender: UIButton) {

        switch sender.tag {
        case 0:
            changeTextAttributes?(0)
            let str = textView.textStorage.string
            let atrStr = NSAttributedString(string: str, attributes: [.font: FontKit.regular.font])
            textView.attributedText = atrStr

//            textView.layoutManager.textStorage.muta
//            mutStr = textView.attributedText
        case 1:
            changeTextAttributes?(1)
            let str = textView.textStorage.string
            let atrStr = NSAttributedString(string: str, attributes: [.font: FontKit.italic.font])
            textView.attributedText = atrStr
//            textView.attributedText = mutStr
        case 2:
            changeTextAttributes?(2)
            let str = textView.textStorage.string
            let atrStr = NSAttributedString(string: str, attributes: [.font: FontKit.bold.font])
            textView.attributedText = atrStr
        default:
            break
        }
//        textView.textStorage.delegate?.textStorageMakeSelectiveEditing(
//            textView.textStorage, willProcessEditing: .init(rawValue: 3),
//            range: textView.selectedRange, changeInLength: 1)
//
//        textView.textStorage.delegate?.textStorage?(textView.textStorage, willProcessEditing: .init(rawValue: 3), range: textView.textStorage.editedRange, changeInLength: 1)
    }

    @objc private func H1ButtonTapped(_ sender: UIBarButtonItem) {
        let str = textView.textStorage.string
        let atrStr = NSAttributedString(string: str, attributes: [.font: FontKit.bold.font])

        textView.attributedText = atrStr




//        textView.textStorage.delegate?.textStorageMakeSelectiveEditing(
//            textView.textStorage, willProcessEditing: .init(rawValue: 3),
//            range: textView.selectedRange, changeInLength: 1)

//        textView.textStorage.removeAttribute(.foregroundColor, range: textView.selectedRange)
//
//        textView.textStorage.delegate?.textStorage?(textView.textStorage, willProcessEditing: .init(rawValue: 3), range: textView.textStorage.editedRange, changeInLength: 1)
        
    }

    var changeTextAttributes: ((Int) -> Void)?
    var changeAttributesTwo: (() -> Void)?


    // MARK: - Init
    init(textViewDelegate: UITextViewDelegate, textStorageDelegate: NSTextStorageDelegate) {
        super.init(frame: .zero)
        textView.delegate = textViewDelegate
        textView.textStorage.delegate = textStorageDelegate
        setupSubviews()
        setupConstraints()
        addToolBar()
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

    lazy var changeText: (() -> Void) = { [weak self] in
        guard let self = self else { return }
        self.textView.font = FontKit.H1.font
    }

    lazy var testToTapp: (() -> UITextRange?) = {
        self.textView.selectedTextRange
    }

    var getSelectedRange: ((UITextRange?) -> Void)?
}

extension NoteScreenView: Setupable {
    func setup(withModel model: ModelProtocol) {
        guard let model = model as? NoteScreenModel.Model else { return }

        if textView.text.isEmpty {
            textView.font = model.textViewFont
        }

    }
}


class LM: NSLayoutManager {
    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        print("🤬🤬🤬🤬")
    }
}

