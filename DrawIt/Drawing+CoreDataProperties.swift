//
//  Drawing+CoreDataProperties.swift
//  DrawIt
//
//  Created by Kristen on 6/5/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Drawing {

    @NSManaged var date: NSTimeInterval
    @NSManaged var image: NSData?
    @NSManaged var title: String?
    @NSManaged var blur: Int64
    @NSManaged var paths: NSSet?

}
