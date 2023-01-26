//
//  MainScreenModel.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

struct MainScreenModel {
    let mainTitle: String
    let mainTitleColor: UIColor
    let mainBackgroundColor: UIColor
    let noteBackground: UIColor

    let cellTitleLabelFont: UIFont
    let cellTitlelabelTextColor: UIColor
    let cellBackgroundColor: UIColor

    let textForEmptyCell: String
    let cellText: String

    let fixedHeaderText: String
    let fixedHeaderFont: UIFont

    let allHeaderText: String
    let allHeaderFont: UIFont

    let noteCountLabelText: String
    let noteCountLabelFont: UIFont

    let addButtonImage: UIImage
    let addButtonImageColor: UIColor

    struct Model: ModelProtocol {
        var noteCount: UInt? = nil
        let mainBackgroundColor: UIColor
        let noteBackground: UIColor



    }

    var model: Model

    init() {
        mainTitle = "Notes"
        mainTitleColor = Palette.mainText.color
        mainBackgroundColor = Palette.mainBackground.color
        noteBackground = Palette.noteBackground.color
        cellTitleLabelFont = FontKit.H2.font
        cellTitlelabelTextColor = Palette.mainText.color
        cellBackgroundColor = Palette.noteBackground.color

        textForEmptyCell = "Empty note"
        cellText = ""

        fixedHeaderText = "Fixed"
        fixedHeaderFont = FontKit.H1.font

        allHeaderText = "All notes"
        allHeaderFont = FontKit.H1.font

        noteCountLabelText = "notes"
        noteCountLabelFont = FontKit.caption.font

        addButtonImage = Images.addButton.image
        addButtonImageColor = Palette.systemElement.color

        model = Model(
            mainBackgroundColor: mainBackgroundColor,
            noteBackground: noteBackground

        )
    }
}
