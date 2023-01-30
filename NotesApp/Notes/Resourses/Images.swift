//
//  Images.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

enum Images {
    case addButton
    case setting

    var image: UIImage {
        switch self {
        case .addButton:
            return UIImage(systemName: "plus.square") ?? UIImage()
        case .setting:
            return UIImage(systemName: "gearshape") ?? UIImage()
        }
    }
}

