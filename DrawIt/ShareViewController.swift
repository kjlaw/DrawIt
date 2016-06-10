//
//  ShareViewController.swift
//  DrawIt
//
//  Created by Kristen on 6/5/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    
    var snapshotImage: UIImage?

    @IBAction func saveImage() {
        if let image = snapshotImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func share() {
        if let image = snapshotImage {
            let sharevc = UIActivityViewController(activityItems: [(image), ""], applicationActivities: nil)
            sharevc.excludedActivityTypes = [UIActivityTypePostToWeibo,
                                            UIActivityTypeMessage,
                                            UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact,
                                            UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAddToReadingList,
                                            UIActivityTypePostToVimeo,
                                            UIActivityTypePostToTencentWeibo]
            self.presentViewController(sharevc, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationvc: UIViewController? = segue.destinationViewController
        if let navcon = destinationvc as? UINavigationController {
            destinationvc = navcon.visibleViewController
        }
        if segue.identifier == "SendImageSegue" {
            if let contactsvc = destinationvc as? ContactsTableViewController {
                contactsvc.snapshotImage = snapshotImage
            }
        }
    }
}
