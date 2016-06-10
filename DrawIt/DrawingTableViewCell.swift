//
//  DrawingTableViewCell.swift
//  DrawIt
//
//  Created by Kristen on 6/2/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit

class DrawingTableViewCell: UITableViewCell {

    var backgroundImage: UIImage?
    var date: NSTimeInterval?
    var blur: Int = 0
    var bezierPaths: [UIBezierPath] = []
    var colors: [UIColor] = []
}
