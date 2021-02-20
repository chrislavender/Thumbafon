//
//  ScaleCreation.swift
//  Thumbafon
//
//  Created by Chris Lavender on 9/15/15.
//  Copyright (c) 2015 Gnarly Dog Music. All rights reserved.
//

import Foundation
import CoreData

extension Scale {
    // MARK: CoreData
    static func baseNoteNumbers() -> [Int] {
        
        let tempIntervals = [2, 2, 3, 2, 2]
    
        var noteNumbers = [0]
        var prevNote = noteNumbers[0]

        for index in 0...tempIntervals.count - 1 {
            let interval = tempIntervals[index]
            let nextNote = prevNote + interval
            noteNumbers.append(nextNote)
            prevNote = nextNote
        }
        
        return noteNumbers
    }
    
    static func scale(name:String, context: NSManagedObjectContext) -> Scale? {
        
        var match: (Scale)? = nil
        
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Scale")
            fetchRequest.predicate = NSPredicate(format: "name == \(name)")
            
            if let fetchResults = try context.fetch(fetchRequest) as? [Scale] {
                match = fetchResults.first
            }
            
        } catch {
            print(error)
        }
        
        return match
    }

}
