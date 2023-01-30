//
//  Palette.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

enum Palette {
    case mainBackground
    case noteBackground
    case mainText
    case text
    case subtext
    case systemElement
    case selected

    private func createColor(lightMode: UIColor, darkMode: UIColor) -> UIColor {
        return UIColor { (traintCollection) -> UIColor in
            return traintCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }

    var color: UIColor {
        switch self {
        case .mainBackground:
            return createColor(
                lightMode: UIColor(red: 0.847, green: 0.859, blue: 0.886, alpha: 1),
                darkMode: UIColor(red: 0.14, green: 0.161, blue: 0.208, alpha: 1)
            )
        case .noteBackground:
            return createColor(
                lightMode: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
                darkMode: UIColor(red: 0.29, green: 0.33, blue: 0.371, alpha: 1)
            )
        case .mainText:
            return createColor(
                lightMode: UIColor(red: 0.14, green: 0.161, blue: 0.208, alpha: 1),
                darkMode: UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            )
        case .text:
            return createColor(
                lightMode: UIColor(red: 0.29, green: 0.33, blue: 0.371, alpha: 1),
                darkMode: UIColor(red: 0.847, green: 0.859, blue: 0.886, alpha: 1)
            )
        case .subtext:
            return createColor(
                lightMode: UIColor(red: 0.773, green: 0.787, blue: 0.821, alpha: 1),
                darkMode: UIColor(red: 0.186, green: 0.206, blue: 0.225, alpha: 1)
            )
        case .systemElement:
            return createColor(
                lightMode: UIColor(red: 0.883, green: 0.655, blue: 0.066, alpha: 1),
                darkMode: UIColor(red: 0.345, green: 0.643, blue: 0.69, alpha: 1)
            )
        case .selected:
            return createColor(
                lightMode: UIColor(red: 0.855, green: 0.643, blue: 0.604, alpha: 1),
                darkMode: UIColor(red: 0.855, green: 0.643, blue: 0.604, alpha: 1)
            )
        }
    }
}
