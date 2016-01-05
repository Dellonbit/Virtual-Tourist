//
//  Photos+CoreDataProperties.swift
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

extension Photos {

    @NSManaged var title: String?
    @NSManaged var path: String?
    @NSManaged var photo: Pin?

}
