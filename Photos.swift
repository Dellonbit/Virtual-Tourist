//
//  Photos.swift
//  Virtual Tourist
//
//  Created by arianne on 2015-12-09.
//  Copyright © 2015 della. All rights reserved.
//

import Foundation
import CoreData

class Photos: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photoTitle:String, urlpath: String, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        //insert core data
        title =  photoTitle
        path  =  urlpath
    }
    
    class func coreDataDeletePhoto(objdel:Photos, context: NSManagedObjectContext){
        
        
//        var error: NSError? = nil
//        context.deleteObject(objdel)
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch let error1 as NSError {
//                error = error1
//                NSLog("Unresolved error \(error), \(error!.userInfo)")
//                abort()
//            }
//         }
        
    }

}
