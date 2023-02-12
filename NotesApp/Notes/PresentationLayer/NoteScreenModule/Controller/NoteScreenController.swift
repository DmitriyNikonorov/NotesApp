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
        let mainView = NoteScreenView(textViewDelegate: self)
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
        mainView.changeTextAttributes = { [weak self] number in
            guard let self = self else { return }
            self.setupTextAttribute(forFont: .init(rawValue: number) ?? .regular)
        }
    }

    private func setupNavigationBar() {
        guard let mainModel = mainModel else { return }
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.titleTextAttributes = [
            .foregroundColor: mainModel.titleColor,
                .font: mainModel.titleFont
        ]
        scrollAppearance.backgroundColor = mainModel.noteBackgroundColor

        navigationController?.navigationBar.scrollEdgeAppearance = scrollAppearance
        navigationController?.navigationBar.standardAppearance = scrollAppearance
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
        textAttribute[.foregroundColor] = mainModel.noteTextColor
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
        if source == .fromMainScreen {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func addButtonDidTapped() {
        if source == .fromMainScreen {
            navigationController?.popViewController(animated: false)
            creatableDelegaet.createNewNote()
        } else {
            dismiss(animated: true)
            creatableDelegaet.createNewNote()
        }
    }

    @objc private func rightBarButtonDidTapped(_ sender: UIBarButtonItem) {
        guard let index = mainModel?.index else { return }
        mainView.hideKeyboard()
        rightBarButtonItem(isShow: false)
        let newText = mainView.getText()
        creatableDelegaet.saveChanges(withString: newText, and: index)
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
    }
}
