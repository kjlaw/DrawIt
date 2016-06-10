//
//  SettingsTableViewController.swift
//  DrawIt
//
//  Created by Kristen on 5/31/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var drawingViewController: DrawingViewController?
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var size: Float {
        get {
            if defaults.objectForKey(UserDefaultsKeys.Size.rawValue) != nil {
                return defaults.floatForKey(UserDefaultsKeys.Size.rawValue)
            }
            return 5.0
        }
        set {
            defaults.setValue(newValue, forKey: UserDefaultsKeys.Size.rawValue)
        }
    }
    
    private var color: UIColor {
        get {
            if let savedColor = defaults.colorForKey(UserDefaultsKeys.Color.rawValue) {
                return savedColor
            }
            return UIColor.blackColor()
        }
        set {
            defaults.setColor(newValue, forKey: UserDefaultsKeys.Color.rawValue)
        }
    }

    enum BlurEffect: Int {
        case None
        case Light
        case Dark
    }
    
    enum UserDefaultsKeys: String {
        case Size = "size"
        case Color = "color"
        case Blur = "blur"
    }

    @IBAction func brushSizeChanged(sender: UISlider) {
        size = sender.value
    }
    
    @IBAction func blurEffectChanged(sender: UISegmentedControl) {
        drawingViewController?.updateBlurEffect(sender.selectedSegmentIndex)
    }
    

    // MARK: - Table view data source
    
    enum Section: Int {
        case Size
        case Color
        case Background
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.None
        
        switch (indexPath.section) {
        case Section.Size.rawValue:
            if let sliderCell = cell as? SizeSliderTableViewCell {
                sliderCell.sizeSlider.setValue(size, animated: false)
            }
        case Section.Color.rawValue:
            if cell.textLabel?.text == "Black" && color == UIColor.blackColor() {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if cell.textLabel?.text == "Red" && color == UIColor.redColor() {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else if cell.textLabel?.text == "Blue" && color == UIColor.blueColor() {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
        case Section.Background.rawValue:
            if let blurCell = cell as? BlurControlTableViewCell,
                drawvc = drawingViewController {
                blurCell.selectionStyle = UITableViewCellSelectionStyle.None
                if drawvc.blur != nil {
                    blurCell.blurControl.selectedSegmentIndex = (drawvc.blur)!
                } else {
                    drawvc.blur = 0
                }
                
            }
            
        default: break
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        switch (indexPath.section) {
        case Section.Color.rawValue:
            if cell.textLabel?.text == "Black" {
                color = UIColor.blackColor()
            } else if cell.textLabel?.text == "Red" {
                color = UIColor.redColor()
            } else if cell.textLabel?.text == "Blue" {
                color = UIColor.blueColor()
            }
            tableView.reloadData()
        case Section.Background.rawValue:
            if let text = cell.textLabel?.text {
                if text.localizedCaseInsensitiveContainsString("remove") {
                    drawingViewController?.removeBackgroundImage()
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
        default: break
        }
    }

}


// adapted from http://stackoverflow.com/questions/1275662/saving-uicolor-to-and-loading-from-nsuserdefaults

extension NSUserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
    
}
