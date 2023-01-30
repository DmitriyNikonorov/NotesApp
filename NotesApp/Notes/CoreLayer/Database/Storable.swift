//
//  Storable.swift
//  Notes
//
//  Created by Дмитрий Никоноров on 30.01.2023.
//

import Foundation
import CoreData

protocol Storable {}
extension NSManagedObject: Storable {}
