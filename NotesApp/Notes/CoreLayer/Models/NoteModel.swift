//
//  NoteModel.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 27.01.2023.
//

import Foundation

struct NoteModel {
    let textInData: Data
    let textInAttributedString: NSAttributedString
    let lastModifiedDate: Date
    let index: Int

    var keyedValues: [String: Any] {
        return [
            "text": self.textInData,
            "date": self.lastModifiedDate,
            "index": self.index
        ]
    }

    init(textInAttributedString: NSAttributedString, lastModifiedDate: Date, index: Int) {
        self.textInAttributedString = textInAttributedString
        self.lastModifiedDate = lastModifiedDate
        self.index = index

        //encodind
        var stringData = Data()
        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: textInAttributedString,
                requiringSecureCoding: false
            )
            stringData = data
        } catch {
            print("error encoding")
        }
        self.textInData = stringData
    }

    init?(noteDataModel: NoteDataModel) {
        self.textInData = noteDataModel.text ?? Data()
        self.lastModifiedDate = noteDataModel.date ?? Date()
        self.index = Int(noteDataModel.index)

        //decoding
        var string = NSAttributedString()
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: textInData)
            unarchiver.requiresSecureCoding = false
            let decodedAttributedString = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! NSAttributedString

            string = decodedAttributedString
        } catch {
            print("error decoding")
        }
        self.textInAttributedString = string
    }
}

