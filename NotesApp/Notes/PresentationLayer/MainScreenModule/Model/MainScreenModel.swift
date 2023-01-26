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

    struct Model: ModelProtocol {
        let mainBackgroundColor: UIColor
        let noteBackground: UIColor
    }

    let model: Model

    init() {
        mainTitle = "Notes"
        mainTitleColor = Palette.mainText.color
        mainBackgroundColor = Palette.mainBackground.color
        noteBackground = Palette.noteBackground.color
        cellTitleLabelFont = .systemFont(ofSize: 14)
        cellTitlelabelTextColor = Palette.mainText.color
        cellBackgroundColor = Palette.noteBackground.color

        textForEmptyCell = "Empty note"
        cellText = ""

        model = Model(mainBackgroundColor: mainBackgroundColor, noteBackground: noteBackground)
    }
}
