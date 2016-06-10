//
//  DrawingsTableViewController.swift
//  DrawIt
//
//  Created by Kristen on 6/1/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit
import CoreData

class DrawingsTableViewController: CoreDataTableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var drawingTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search for saved drawings..."
        tableView.tableHeaderView = self.searchController.searchBar
        definesPresentationContext = true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        let trimmedSearchString = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if !trimmedSearchString.isEmpty {
            let predicate = NSPredicate(format: "(title contains [cd] %@)", trimmedSearchString)
            fetchedResultsController?.fetchRequest.predicate = predicate
        } else {
            updateUI()
        }

        self.fetchedResultsController = fetchedResultsController
    }

    @IBAction func createNewDrawing(sender: UIBarButtonItem) {
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Create New Drawing", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter title here"
            inputTextField = textField
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { [unowned self] action in
            self.drawingTitle = inputTextField?.text
            self.performSegueWithIdentifier("CreateSegue", sender: self)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let context = managedObjectContext {
            let request = NSFetchRequest(entityName: "Drawing")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            fetchedResultsController = nil
        }
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DrawingCell", forIndexPath: indexPath)
        if let drawing = fetchedResultsController?.objectAtIndexPath(indexPath) as? Drawing,
            drawingCell = cell as? DrawingTableViewCell {
            var title: String?
            var image: UIImage?
            var blur: Int = 0
            var date: NSTimeInterval?
            var bezierPaths: [UIBezierPath] = []
            var colors: [UIColor] = []
            drawing.managedObjectContext?.performBlockAndWait {
                title = drawing.title
                date = drawing.date
                blur = Int(drawing.blur)
                if let paths = drawing.paths?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "index", ascending: true)]) as? [Path] {
                    for path in paths {
                        bezierPaths.append(NSKeyedUnarchiver.unarchiveObjectWithData(path.bezier!)! as! UIBezierPath)
                        colors.append(NSKeyedUnarchiver.unarchiveObjectWithData(path.color!)! as! UIColor)
                    }
                }
                if let data = drawing.image {
                    image = UIImage(data: data)
                }
            }
            drawingCell.textLabel?.text = title
            drawingCell.backgroundImage = image
            drawingCell.date = date!
            drawingCell.blur = blur
            drawingCell.bezierPaths = bezierPaths
            drawingCell.colors = colors
        }

        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        managedObjectContext = AppDelegate.managedObjectContext
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationvc: UIViewController? = segue.destinationViewController
        if segue.identifier == "CreateSegue" {
            if let drawingvc = destinationvc as? DrawingViewController {
                drawingvc.title = drawingTitle
            }
        } else if segue.identifier == "EditSegue" {
            if let drawingvc = destinationvc as? DrawingViewController,
                drawingCell = sender as? DrawingTableViewCell {
                drawingvc.title = drawingCell.textLabel?.text
                drawingvc.backgroundImage = drawingCell.backgroundImage
                drawingvc.blur = drawingCell.blur
                drawingvc.bezierPaths = drawingCell.bezierPaths
                drawingvc.colors = drawingCell.colors
                drawingvc.editingSavedDrawing = true
                drawingvc.lastModifiedDate = drawingCell.date!
            }
        }
    }

}
