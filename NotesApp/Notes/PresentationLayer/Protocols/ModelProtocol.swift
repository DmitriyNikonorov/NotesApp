//
//  ModelProtocol.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 26.01.2023.
//

import Foundation

protocol ModelProtocol {}

protocol Setupable {
    func setup(withModel model: ModelProtocol)
}
