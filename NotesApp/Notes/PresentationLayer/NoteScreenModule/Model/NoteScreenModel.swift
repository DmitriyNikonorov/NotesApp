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

    let regularFont: UIFont
    let italicFont: UIFont
    let boldFont: UIFont

    struct Model: ModelProtocol {
        let textViewFont: UIFont
    }

    let model: Model

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
        regularFont = FontKit.regular.font
        italicFont = FontKit.italic.font
        boldFont = FontKit.bold.font
        
        model = Model(
            textViewFont: FontKit.textBody.font
        )
    }
}
