//
//  Path.swift
//  DrawIt
//
//  Created by Kristen on 6/5/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Path: NSManagedObject {

    class func pathWithBezierAndColorAndIndex(bezier: UIBezierPath, color: UIColor, index: Int64, forDrawing drawing: Drawing, inManagedObjectContext context: NSManagedObjectContext) -> Path? {
        
        if let path = NSEntityDescription.insertNewObjectForEntityForName("Path", inManagedObjectContext: context) as? Path {
            path.color = NSKeyedArchiver.archivedDataWithRootObject(color)
            path.bezier = NSKeyedArchiver.archivedDataWithRootObject(bezier)
            path.index = index
            path.drawing = drawing
            
            return path
        }
        
        return nil
    }

}
