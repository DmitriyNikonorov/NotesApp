//
//  Enums.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

enum CollectionReuseIdentifiers: String {
    case note
    case header
}

enum Constants {
    static let itemHeight: CGFloat = 50.0
    static let spacing: CGFloat = 8.0
    static let insets: CGFloat = 12.0
}


enum NoteFonts: Int {
    case regular, italic, bold
}
