//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-12-09.
//  Copyright © 2015 della. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var pages: NSNumber?
    @NSManaged var pin: NSManagedObject?
    
}
