//
//  Pin.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-12-09.
//  Copyright © 2015 della. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
   
    var photos = [Photos]()
    var magic = "hahahah"
// Insert code here to add functionality to your managed object subclass
// @NSManaged var photos: [Photos]?
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(lat:Double, long: Double, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        //insert core data
        latitude =  lat as NSNumber
        longitude =  long as NSNumber
    }
    
   class func coreDataDeletePin(objdel:Pin, context: NSManagedObjectContext){
        var error: NSError? = nil
        context.deleteObject(objdel)
        if context.hasChanges {
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}