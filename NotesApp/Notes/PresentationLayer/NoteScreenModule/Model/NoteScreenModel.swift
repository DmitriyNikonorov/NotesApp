//
//  NoteScreenModel.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 27.01.2023.
//

import Foundation
import UIKit

struct NoteScreenModel: ModelProtocol {
    let noteBackgroundColor: UIColor
    let backButtonImage: UIImage
    let backButtonImageColor: UIColor
    let rightButtonTitle: String
    let rightButtonTitleColor: UIColor
    let addButtonImage: UIImage
    let editButtonImage: UIImage
    let toolBarImageColor: UIColor
    let noteTextColor: UIColor

    let titleColor: UIColor
    let titleFont: UIFont

    var time: String?
    var index: Int?

    let regularFont: UIFont
    let italicFont: UIFont
    let boldFont: UIFont

    struct Model: ModelProtocol {
        let textViewFont: UIFont
        var noteText: NSAttributedString?

        let boldButtonText: String
        let boldButtonAttributes: [NSAttributedString.Key : Any]

        let italicButtonText: String
        let italicButtonAttributes: [NSAttributedString.Key : Any]

        let regularButtonText: String
        let regularButtonAttributes: [NSAttributedString.Key : Any]
    }

    var model: Model

    init() {
        noteBackgroundColor = Palette.noteBackground.color
        backButtonImage = Images.back.image
        backButtonImageColor = Palette.systemElement.color
        rightButtonTitle = "Save"
        rightButtonTitleColor = Palette.systemElement.color
        addButtonImage = Images.add.image
        editButtonImage = Images.edit.image
        toolBarImageColor = Palette.systemElement.color
        noteTextColor = Palette.mainText.color
        titleColor = Palette.subtext.color
        titleFont = FontKit.underlineBody.font
        regularFont = FontKit.regularNoteText.font
        italicFont = FontKit.italicNoteText.font
        boldFont = FontKit.boldNoteText.font
        
        model = Model(
            textViewFont: FontKit.body.font,
            boldButtonText: "Bold",
            boldButtonAttributes:
                [.font: FontKit.boldNoteText.font, .foregroundColor: Palette.mainText.color],
            italicButtonText: "Italic",
            italicButtonAttributes:
                [.font: FontKit.italicNoteText.font, .foregroundColor: Palette.mainText.color],
            regularButtonText: "Regular",
            regularButtonAttributes:
                [.font: FontKit.regularNoteText.font, .foregroundColor: Palette.mainText.color]
        )
    }
}
