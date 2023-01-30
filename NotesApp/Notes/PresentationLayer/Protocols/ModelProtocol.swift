//
//  ModelProtocol.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation
import UIKit

protocol ModelProtocol {}

protocol Setupable {
    func setup(withModel model: ModelProtocol)
}
