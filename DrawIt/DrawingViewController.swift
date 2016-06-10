//
//  DrawingViewController.swift
//  DrawIt
//
//  Created by Kristen on 5/31/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit
import CoreData

class DrawingViewController: UIViewController, UIPopoverPresentationControllerDelegate, ImagePickerViewControllerDelegate {

    @IBOutlet weak var snapshotView: UIView!
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var drawingViewImage: UIImageView!
    
    var backgroundImage: UIImage?
    
    var bezierPaths: [UIBezierPath] = []
    var colors: [UIColor] = []
    var blur: Int?
    
    var editingSavedDrawing: Bool = false
    var lastModifiedDate: NSTimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = backgroundImage {
            drawingViewImage.contentMode = .ScaleAspectFill
            drawingViewImage.image = image
            
            updateBlurEffect(blur!)
        }

        drawingView.setPaths(bezierPaths, colors: colors)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        let (bezierPaths, colors) = drawingView.getPaths()
        if blur == nil {
            blur = 0
        }
        updateDatabase(editingSavedDrawing, title: title, date: lastModifiedDate, image: backgroundImage, blur: blur!, bezierPaths: bezierPaths, colors: colors)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func updateDatabase(editing: Bool, title: String?, date: NSTimeInterval, image: UIImage?, blur: Int, bezierPaths: [UIBezierPath], colors: [UIColor]) {
        if let context = AppDelegate.managedObjectContext where title != nil {
            context.performBlock {
                if (editing) {
                    Drawing.drawingWithUpdatedComponents(title!, date: date, image: image, blur: blur, bezierPaths: bezierPaths, colors: colors, inManagedObjectContext: context)
                } else {
                    Drawing.drawingWithComponents(title!, image: image, blur: blur, bezierPaths: bezierPaths, colors: colors, inManagedObjectContext: context)
                }
                do {
                    try context.save()
                } catch let error {
                    print("Core Data Error: \(error)")
                }
            }
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func undo(sender: UIBarButtonItem) {
        drawingView.undoLastStrokeIfPossible()
    }
    
    func updateBlurEffect(blur: Int) {
        self.blur = blur
        for subview in drawingViewImage.subviews {
            subview.removeFromSuperview()
        }
        if blur != SettingsTableViewController.BlurEffect.None.rawValue {
            var style = UIBlurEffectStyle.Light
            if blur == SettingsTableViewController.BlurEffect.Dark.rawValue {
                style = UIBlurEffectStyle.Dark
            }
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            visualEffectView.frame = drawingViewImage.bounds
            drawingViewImage.addSubview(visualEffectView)
        }
    }
    
    func removeBackgroundImage() {
        backgroundImage = nil
        drawingViewImage.image = nil
    }
    
    private func getScreenshotImage(fromView view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setImagePicked(image: UIImage) {
        backgroundImage = image
        drawingViewImage.contentMode = .ScaleAspectFill
        drawingViewImage.image = backgroundImage
        dismiss()
    }
    
    //-- MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "SettingsSegue" || segue.identifier == "ShareSegue" || segue.identifier == "ImagePickerSegue") {
            let vc = segue.destinationViewController
            vc.popoverPresentationController?.delegate = self
            if (segue.identifier == "ShareSegue") {
                if let sharevc = vc as? ShareViewController {
                    let image = getScreenshotImage(fromView: snapshotView)
                    sharevc.snapshotImage = image
                    sharevc.preferredContentSize = CGSizeMake(300,200)
                    sharevc.title = "Share"
                }
            }
            if (segue.identifier == "SettingsSegue") {
                if let settingsvc = vc as? SettingsTableViewController {
                    settingsvc.drawingViewController = self
                }
            }
            if (segue.identifier == "ImagePickerSegue") {
                if let imagepickervc = vc as? ImagePickerViewController {
                    imagepickervc.delegate = self
                    imagepickervc.preferredContentSize = CGSizeMake(300,200)
                    imagepickervc.title = "Set Background Image"
                }
            }
            return
        }
    }
    
    // adapted from http://stackoverflow.com/questions/25275271/close-button-on-adaptive-popover
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let btnDone = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(dismiss))
        let nav = UINavigationController(rootViewController: controller.presentedViewController)
        nav.topViewController?.navigationItem.rightBarButtonItem = btnDone
        return nav
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

