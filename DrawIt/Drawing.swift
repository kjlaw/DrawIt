//
//  Drawing.swift
//  DrawIt
//
//  Created by Kristen on 6/2/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Drawing: NSManagedObject {

    class func drawingWithComponents(title: String, image: UIImage?, blur: Int, bezierPaths: [UIBezierPath], colors: [UIColor], inManagedObjectContext context: NSManagedObjectContext) -> Drawing? {
        
        if let drawing = NSEntityDescription.insertNewObjectForEntityForName("Drawing", inManagedObjectContext: context) as? Drawing {
            drawing.title = title
            if let img = image {
                drawing.image = drawing.getImageData(img)
            }
            drawing.blur = Int64(blur)
            drawing.date = NSDate().timeIntervalSinceReferenceDate
            
            for (index, path) in bezierPaths.enumerate() {
                Path.pathWithBezierAndColorAndIndex(path, color: colors[index], index: Int64(index), forDrawing: drawing, inManagedObjectContext: context)
            }
            
            return drawing
        }
        
        return nil
    }
    
    class func drawingWithUpdatedComponents(title: String, date: NSTimeInterval, image: UIImage?, blur: Int, bezierPaths: [UIBezierPath], colors: [UIColor], inManagedObjectContext context: NSManagedObjectContext) -> Drawing? {
        
        let request = NSFetchRequest(entityName: "Drawing")
        request.predicate = NSPredicate(format: "title = %@ AND date = %@", title, NSDate.init(timeIntervalSinceReferenceDate: date))
        
        if let drawing = (try? context.executeFetchRequest(request))?.first as? Drawing {
            if let img = image {
                drawing.image = drawing.getImageData(img)
            } else {
                drawing.image = nil
            }
            drawing.blur = Int64(blur)
            drawing.date = NSDate().timeIntervalSinceReferenceDate
            
            for (index, path) in bezierPaths.enumerate() {
                let pathRequest = NSFetchRequest(entityName: "Path")
                pathRequest.predicate = NSPredicate(format: "index = %d AND drawing = %@", index, drawing)
                
                if ((try? context.executeFetchRequest(pathRequest))?.first as? Path) != nil {
                    // if path already exists, don't re-add it
                    continue
                } else {
                    Path.pathWithBezierAndColorAndIndex(path, color: colors[index], index: Int64(index), forDrawing: drawing, inManagedObjectContext: context)
                }
            }
            
            return drawing
        }
        
        return nil
    }
    
    private func getImageData(image: UIImage) -> NSData? {
        return UIImageJPEGRepresentation(image, 1);
    }

}
