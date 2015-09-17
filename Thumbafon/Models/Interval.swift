//
//  Interval.swift
//  
//
//  Created by Chris Lavender on 9/15/15.
//
//

import Foundation
import CoreData

class Interval: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var steps: NSNumber
    @NSManaged var intervals: NSSet

}
