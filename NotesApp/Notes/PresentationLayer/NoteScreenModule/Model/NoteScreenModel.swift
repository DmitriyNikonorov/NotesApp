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

    let titleColor: UIColor
    let titleFont: UIFont

    var time: String?
//    var noteText: NSAttributedString?

    let regularFont: UIFont
    let italicFont: UIFont
    let boldFont: UIFont

    struct Model: ModelProtocol {
        let textViewFont: UIFont
        var noteText: NSAttributedString?
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
        titleColor = Palette.subtext.color
        titleFont = FontKit.underlineBody.font
        regularFont = FontKit.regularNoteText.font
        italicFont = FontKit.italicNoteText.font
        boldFont = FontKit.boldNoteText.font
        
        model = Model(
            textViewFont: FontKit.body.font
        )
    }
}
