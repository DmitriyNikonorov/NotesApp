//
//  Creatable.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 30.01.2023.
//

import Foundation

protocol Creatable {
    func getNewTime() -> String
    func createNewNote()
    func saveChanges(withString string: NSAttributedString, and index: Int)
}
