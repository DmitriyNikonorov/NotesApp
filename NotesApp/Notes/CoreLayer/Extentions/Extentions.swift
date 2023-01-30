//
//  Extentions.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

extension UIView {
    func toAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { addSubview($0)}
    }
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
      }
}

extension String {
    static let empty = ""
    static let whitespace: Character = " "

    /// Replacing a pattern with a string
    /// - Parameters:
    ///   - pattern: Regex pattern
    ///   - replacement: The string to replace the pattern with
    func replace(_ pattern: String, replacement: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        return regex.stringByReplacingMatches(
            in: self,
            options: [.withTransparentBounds],
            range: NSRange(location: 0, length: self.count),
            withTemplate: replacement
        )
    }
}
