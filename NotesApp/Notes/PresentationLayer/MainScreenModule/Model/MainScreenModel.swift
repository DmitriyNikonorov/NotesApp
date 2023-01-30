//
//  MainScreenModel.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

struct MainScreenModel: ModelProtocol {
    let mainTitle: String
    let mainTitleColor: UIColor
    let mainBackgroundColor: UIColor
    let noteBackground: UIColor

    let cellTitleLabelFont: UIFont
    let cellTitlelabelTextColor: UIColor
    let cellNormalBackgroundColor: UIColor
    let cellSelectedBackgroundColor: UIColor

    let textForEmptyCell: NSAttributedString
    let cellText: String

    let fixedHeaderText: String
    let fixedHeaderFont: UIFont

    let allHeaderText: String
    let allHeaderFont: UIFont

    let noteCountLabelText: String
    let noteCountLabelFont: UIFont

    let addButtonImage: UIImage
    let addButtonImageColor: UIColor

    let settingButtonImage: UIImage
    let settingButtonImageColor: UIColor

    let regularFont: UIFont
    let italicFont: UIFont
    let boldFont: UIFont

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
        cellNormalBackgroundColor = Palette.noteBackground.color
        cellSelectedBackgroundColor = Palette.selected.color

        textForEmptyCell = NSAttributedString(
            string: "Empty note",
            attributes: [.font: FontKit.body.font, .foregroundColor: Palette.mainText.color]
        )
        cellText = ""

        fixedHeaderText = "Fixed"
        fixedHeaderFont = FontKit.H1.font

        allHeaderText = "All notes"
        allHeaderFont = FontKit.H1.font

        noteCountLabelText = "notes"
        noteCountLabelFont = FontKit.caption.font

        addButtonImage = Images.add.image
        addButtonImageColor = Palette.systemElement.color

        settingButtonImage = Images.setting.image
        settingButtonImageColor = Palette.systemElement.color

        regularFont = FontKit.regularNoteText.font
        italicFont = FontKit.italicNoteText.font
        boldFont = FontKit.boldNoteText.font

        model = Model(
            mainBackgroundColor: mainBackgroundColor,
            noteBackground: noteBackground

        )
    }
}
