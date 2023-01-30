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
    case underlineBody
    case caption

    var font: UIFont {
        switch self {
        case .H1:
            return .boldSystemFont(ofSize: 20)
        case .H2:
            return .boldSystemFont(ofSize: 12)
        case .body:
            return .systemFont(ofSize: 14)
        case .underlineBody:
            return .systemFont(ofSize: 12)
        case .caption:
            return .systemFont(ofSize: 10)
        }
    }
}

