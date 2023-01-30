//
//  FontKit.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

enum FontKit {
    case H1
    case H2
    case body
//    case textBody
    case underlineBody
    case caption

    case regularNoteText
    case italicNoteText
    case boldNoteText

    var font: UIFont {
        switch self {
        case .H1:
            guard let font = UIFont(name: "Rubik-Medium", size: 20) else {
                return UIFont.systemFont(ofSize: 20)
            }
            return font
        case .H2:
            guard let font = UIFont(name: "Rubik-Medium", size: 12) else {
                return UIFont.systemFont(ofSize: 12)
            }
            return font
        case .body:
            guard let font = UIFont(name: "Rubik-Regular", size: 14) else {
                return UIFont.systemFont(ofSize: 14)
            }
            return font
//        case .textBody:
//            guard let font = UIFont(name: "Rubik-Regular", size: 18) else {
//                return UIFont.systemFont(ofSize: 18)
//            }
//            return font
        case .underlineBody:
            guard let font = UIFont(name: "Rubik-Regular", size: 12) else {
                return UIFont.systemFont(ofSize: 12)
            }
            return font
        case .caption:
            guard let font = UIFont(name: "Rubik-Regular", size: 10) else {
                return UIFont.systemFont(ofSize: 10)
            }
            return font
        case .regularNoteText:
            guard let font = UIFont(name: "Rubik-Regular", size: 16) else {
                return UIFont.italicSystemFont(ofSize: 16)
            }
            return font
        case .italicNoteText:
            guard let font = UIFont(name: "Rubik-Italic", size: 16) else {
                return UIFont.italicSystemFont(ofSize: 16)
            }
            return font
        case .boldNoteText:
            guard let font = UIFont(name: "Rubik-Bold", size: 16) else {
                return UIFont.italicSystemFont(ofSize: 16)
            }
            return font
        }
    }
}

