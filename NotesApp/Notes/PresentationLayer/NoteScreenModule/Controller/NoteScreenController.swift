//
//  NoteScreenController.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 27.01.2023.
//

import Foundation
import UIKit

final class NoteScreenController: BasicViewController {
    // MARK: - Properties
    private var mainModel: NoteScreenModel?
    private var creatableDelegaet: Creatable

    private var source: CreationSource

    private lazy var textAttribute: [NSAttributedString.Key: Any] = [:]
    private lazy var mainView: NoteScreenView = {
        let mainView = NoteScreenView(textViewDelegate: self, textStorageDelegate: self)
        return mainView
    }()

    // MARK: - Methods
    private func setupModel(model: ModelProtocol) {
        guard let newModel = model as? NoteScreenModel else { return }
        mainModel = newModel
    }

    private func setupMainView(model: NoteScreenModel?) {
        guard let model = model else { return }
        view.backgroundColor = model.noteBackgroundColor
        mainView.setup(withModel: model.model)
//        mainView.getSelectedRange = { range in
////            print("range from controller is: \(range)")
//        }
        mainView.changeTextAttributes = { [weak self] number in
            guard let self = self else { return }
            self.setupTextAttribute(forFont: .init(rawValue: number) ?? .regular)
        }
    }

    private func setupNavigationBar() {
        guard let mainModel = mainModel else { return }
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.backgroundColor = mainModel.noteBackgroundColor
        scrollAppearance.titleTextAttributes = [
            .foregroundColor: mainModel.titleColor,
                .font: mainModel.titleFont
        ]
        let standartAppearance = UINavigationBarAppearance()
        standartAppearance.titleTextAttributes = [.foregroundColor : UIColor.red]
        standartAppearance.backgroundColor = mainModel.noteBackgroundColor

        navigationController?.navigationBar.scrollEdgeAppearance = scrollAppearance
        navigationController?.navigationBar.standardAppearance = standartAppearance
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: mainModel.backButtonImage,
            style: .plain,
            target: self,
            action: #selector(leftButtonDidTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = mainModel.backButtonImageColor
        title = mainModel.time
    }

    private func rightBarButtonItem(isShow: Bool) {
        guard let mainModel = mainModel else { return }

        if isShow {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: mainModel.rightButtonTitle,
                style: .plain,
                target: self,
                action: #selector(rightBarButtonDidTapped)
            )
            navigationItem.rightBarButtonItem?.tintColor = mainModel.rightButtonTitleColor
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func createToolbar(){
        guard let mainModel = mainModel else { return }
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = mainModel.noteBackgroundColor
        navigationController?.toolbar.standardAppearance = appearance
        navigationController?.toolbar.scrollEdgeAppearance = appearance

        var buttons = [UIBarButtonItem]()
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        //button
        let tintedEditImage = mainModel.editButtonImage.withRenderingMode(.alwaysTemplate)
        let editButon = UIBarButtonItem(
            image: tintedEditImage,
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
        editButon.tintColor = mainModel.toolBarImageColor
        buttons.append(editButon)
        //indent
        buttons.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        //button
        let tintedAddImage = mainModel.addButtonImage.withRenderingMode(.alwaysTemplate)
        let addButon = UIBarButtonItem(
            image: tintedAddImage,
            style: .plain,
            target: self,
            action: #selector(addButtonDidTapped)
        )
        addButon.tintColor = mainModel.toolBarImageColor
        buttons.append(addButon)

        toolbarItems = buttons
        navigationController?.setToolbarHidden(false, animated: false)
    }

    private func setupTextAttribute(forFont font: NoteFonts) {
        guard let mainModel = mainModel else {
            return
        }
        switch font {
        case .regular:
            textAttribute[.font] = mainModel.regularFont
        case .italic:
            textAttribute[.font] = mainModel.italicFont
        case .bold:
            textAttribute[.font] = mainModel.boldFont
        }
    }

    //MARK: - Objc methods

    @objc private func leftButtonDidTapped(_ sender: UIBarButtonItem) {
        //Полуть диапазон выделенного текста
//        let range = mainView.testToTapp()
//        print("range \(range)")
        if source == .fromMainScreen {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }


    }
    
    @objc private func addButtonDidTapped() {
        print("add tapped")
        if source == .fromMainScreen {
            navigationController?.popViewController(animated: false)
            creatableDelegaet.createNewNote()
        } else {
            dismiss(animated: true)
            creatableDelegaet.createNewNote()
        }


    }

    @objc private func editTapped(_ sender: UIBarButtonItem) {
//        mainView.changeText()
    }

    @objc private func rightBarButtonDidTapped(_ sender: UIBarButtonItem) {
        mainView.hideKeyboard()
        rightBarButtonItem(isShow: false)
        let newTime = creatableDelegaet.getNewTime()
        title = newTime
    }

    @objc private func updateTextView(from notification: Notification) {
        let userInfo = notification.userInfo

        guard let getKeyboardRect = (
            userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        )?.cgRectValue else { return }

        let keyboradFrame = view.convert(getKeyboardRect, to: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            mainView.actionAfterKeyboardNotification(.zero)
        } else if notification.name == UIResponder.keyboardWillShowNotification {
            mainView.actionAfterKeyboardNotification(
                UIEdgeInsets(top: 0, left: 0, bottom: keyboradFrame.height, right: 0)
            )
            rightBarButtonItem(isShow: true)
        }
    }

    // MARK: - Init
    init(creatableDelegaet: Creatable, model: ModelProtocol, source: CreationSource) {
        self.creatableDelegaet = creatableDelegaet
        self.source = source
        super.init(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecyrcle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModel(model: model)
        setupView(mainView)
        setupMainView(model: mainModel)
        setupConstraints(ofMainView: mainView)
        setupNavigationBar()
        createToolbar()
        setupTextAttribute(forFont: .regular)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(updateTextView),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(updateTextView),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = nil
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}


//MARK: - Extention
extension NoteScreenController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let attrText = NSAttributedString(string: textView.textStorage.string, attributes: textAttribute)
        textView.attributedText = attrText


//        textStorage.addAttributes(textAttribute, range: editedRange)

//        print("textView \(textView.text)")
//        if textView.text == "R" {
//            textView.text = "1"
//        }
//        MARK: - WORK!!
//        print(textView.text)
//        print(textView.textStorage.editedRange)
//        print(textView.layoutManager.extraLineFragmentRect)
//
//        let startPosition: UITextPosition = textView.beginningOfDocument
//        print("startPosition \(startPosition)")
//
//        //The very end of the text field text:
//        let endPosition: UITextPosition = textView.endOfDocument
//        print("endPosition \(endPosition)")
//
//        //The currently selected range:
//        let selectedRange: UITextRange? = textView.selectedTextRange
//        print("selectedRange \(selectedRange)")
//
//        if let selectedRange = textView.selectedTextRange {
//            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
//            print("\(cursorPosition)")
//        }
//
//        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)
//
//        let newPosition = textView.beginningOfDocument
//        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
    }
    

//    func textViewDidChangeSelection(_ textView: UITextView) {
////        print(textView.text)
////        print("textViewDidChangeSelection \(textView.selectedRange)")
//
//    }
//
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
////        print("textViewShouldBeginEditing \(textView.selectedRange)")
//        return true
//    }
//
//
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        //После свертывания клавиатуры
////        print(textView.text)
//        return true
//    }
////
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

//        let string = text
//        let attributedString = NSMutableAttributedString(string: string)
//
////        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 0, length: 1))
//
//        print(textView.layoutManager.textStorage?.length)
//
//        let length = textView.layoutManager.textStorage?.length ?? 1
//
//        attributedString.addAttribute(
//            .foregroundColor,
//            value: Palette.mainText.color,
//            range: range
//        )
//        attributedString.addAttribute(
//            .font,
//            value: FontKit.H1.font,
//            range: range
//        )
//
//
//
////        string.addAttributes([.foregroundColor: UIColor.gray], range: textView.ra)
//        print("🤬")
//        print("string:\(string)")
//
//        print("👻")
//        print("textView \(textView.text)")
////        print("text \(text)")
//
//        textView.attributedText = attributedString
//



//        print("😡range \(range)")
//        print("😡text \(text)")

//        func createAttributedText(stringText: String) {
//            let stringCount = stringText.count
//            let string: NSMutableAttributedString = NSMutableAttributedString(string: stringText)
//
//            string.addAttributes([.foregroundColor: UIColor.red], range: range)
//
//            textView.attributedText =  string
//        }
//
//        createAttributedText(stringText: textView.text)
//
//        //encodind
//        var stringData = Data()
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: textView.attributedText ?? "", requiringSecureCoding: false) // attributedString is NSAttributedString
//            stringData = data
//            print(stringData)
//        } catch {
//            print("error encoding")
//        }
//
//        var string = NSAttributedString()
//        //decoding
//        do {
//            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: stringData)
//            unarchiver.requiresSecureCoding = false
//            let decodedAttributedString = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! NSAttributedString
//
//            string = decodedAttributedString
//        } catch {
//            print("error decoding")
//        }
//
//        textView.attributedText = string
        return true
    }

//
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
//
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        
//        func createAttributedText(stringText: String) {
//            let stringCount = stringText.count
//            let string: NSMutableAttributedString = NSMutableAttributedString(string: stringText)
//
//            string.addAttributes([.foregroundColor: UIColor.red], range: NSMakeRange(0, stringCount))
//
//            textView.attributedText = string
//        }
//
//        createAttributedText(stringText: textView.text)

        return false
    }
}

extension NoteScreenController: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
//        //encodind
//        var stringData = Data()
//        do {
//            let data = try NSKeyedArchiver.archivedData(
//                withRootObject: textStorage.mutableString,
//                requiringSecureCoding: false
//            ) // attributedString is NSAttributedString
//            stringData = data
//            print(stringData)
//        } catch {
//            print("error encoding")
//        }
//
//        var string = NSMutableAttributedString()
//
//
//        //decoding
//        do {
//            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: stringData)
//            unarchiver.requiresSecureCoding = false
//            let decodedAttributedString = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! NSMutableAttributedString
//
//            string = decodedAttributedString
//        } catch {
//            print("error decoding")
//        }



        //MARK: - WORK
//        textStorage.addAttributes(textAttribute, range: editedRange)
    }


    func textStorage(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
//        print("❤️ \(textStorage.string)")
//        print("editedMask \(editedMask)")
//        textStorage.addAttribute(.font, value: FontKit.H1.font, range: editedRange)
//        textStorage.addAttribute(.foregroundColor, value: Palette.mainText.color, range: editedRange)


    }
}

extension NSTextStorageDelegate {
    func textStorageMakeSelectiveEditing(
        _ textStorage: NSTextStorage,
        willProcessEditing editedMask: NSTextStorage.EditActions,
        range editedRange: NSRange,
        changeInLength delta: Int
    ) {
//        print("❤️ \(textStorage.string)")
//        print("editedRange \(editedRange)")

//        textStorage.removeAttribute(.foregroundColor, range: editedRange)
//        textStorage.addAttribute(.foregroundColor, value: UIColor.black, range: editedRange)


//        func applyFontTraits(NSFontTraitMask, range: NSRange)

//        let str = NSMutableAttributedString(string: textStorage.string, attributes: [.font: FontKit.H1.font])

        let string = NSAttributedString(string: textStorage.string, attributes: [.font: FontKit.H1.font])
        textStorage.replaceCharacters(in: editedRange, with: string)
    }

}




//extension UITextViewDelegate {
//    func textView(_ textView: UITextView, changeTextIn range: NSRange, replacementText text: String) {
////        print("range from controller is: \(textView.selectedRange)")
//
////        string.addAttributes([.foregroundColor: UIColor.red], range: NSMakeRange(0, stringCount))
////        textView.attributedText =  string
//
//
////        guard let range = Range(range, in: textView.text) else { return }
////        var allText = text
////        let subText = allText[range]
////
////        let attributedText = NSAttributedString(string: String(subText), attributes: [.foregroundColor: UIColor.red])
////        print("👻 \(attributedText)")
////
////        allText.replaceSubrange(range, with: "22")
////        print("allText: \(allText)")
////        textView.attributedText = allText
////        testString.replaceSubrange(range, with: new)
//
//
//    }
//}
