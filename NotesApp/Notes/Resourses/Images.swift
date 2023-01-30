//
//  Images.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

enum Images {
    case add
    case setting
    case back
    case edit

    var image: UIImage {
        switch self {
        case .add:
            return UIImage(systemName: "plus.square") ?? UIImage()
        case .setting:
            return UIImage(systemName: "gearshape") ?? UIImage()
        case .back:
            return UIImage(systemName: "chevron.backward") ?? UIImage()
        case .edit:
            return UIImage(systemName: "slider.horizontal.3") ?? UIImage()
        }
    }
}

