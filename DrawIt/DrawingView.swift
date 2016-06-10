//
//  DrawingView.swift
//  DrawIt
//
//  Created by Kristen on 5/31/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit

class DrawingView: UIView {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var paths: [UIBezierPath] = []
    private var colors: [UIColor] = []
    private var currPathIndex = 0
    private var initialPathIndex = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let path = UIBezierPath()
        paths.append(path)
        
        var color: UIColor = UIColor.blackColor()
        if let savedColor = defaults.colorForKey(SettingsTableViewController.UserDefaultsKeys.Color.rawValue) {
            color = savedColor
        }
        colors.append(color)
        
        let point = touches.first?.locationInView(self)
        if point != nil {
            paths[currPathIndex].moveToPoint(point!)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let point = touches.first?.locationInView(self)
        if point != nil {
            paths[currPathIndex].addLineToPoint(point!)
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesMoved(touches, withEvent: event)
        currPathIndex += 1
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if touches != nil {
            touchesEnded(touches!, withEvent: event)
        }
    }
    
    func undoLastStrokeIfPossible() {
        if currPathIndex > initialPathIndex {
            paths.removeLast()
            colors.removeLast()
            currPathIndex -= 1
            setNeedsDisplay()
        }
    }
    
    func getPaths() -> ([UIBezierPath], [UIColor]) {
        return (paths, colors)
    }
    
    func setPaths(bezierPaths: [UIBezierPath], colors: [UIColor]) {
        self.paths = bezierPaths
        self.colors = colors
        initialPathIndex = paths.count
        currPathIndex = paths.count
        setNeedsDisplay()
    }

    override func drawRect(rect: CGRect) {
        // Drawing code
        var size: Float = 5.0
        if defaults.objectForKey(SettingsTableViewController.UserDefaultsKeys.Size.rawValue) != nil {
            size = defaults.floatForKey(SettingsTableViewController.UserDefaultsKeys.Size.rawValue)
        }
        
        if currPathIndex < paths.count {
            paths[currPathIndex].lineWidth = CGFloat(size)
            paths[currPathIndex].lineCapStyle = CGLineCap.Round
        }
        
        strokePaths()
    }
    
    private func strokePaths() {
        for (index, path) in paths.enumerate() {
            colors[index].setStroke()
            path.stroke()
        }
    }

}
