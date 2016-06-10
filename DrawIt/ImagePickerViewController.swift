//
//  ImagePickerViewController.swift
//  DrawIt
//
//  Created by Kristen on 6/5/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit

protocol ImagePickerViewControllerDelegate {
    func setImagePicked(image: UIImage)
}

class ImagePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var delegate: ImagePickerViewControllerDelegate?
    var url: NSURL? {
        didSet {
            fetchImage()
        }
    }
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate?.setImagePicked(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func chooseFromLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func takeFromCamera() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func downloadFromUrl() {
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Enter Image URL: ", message: "", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Paste URL here"
            inputTextField = textField
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { [unowned self] action in
            if let text = inputTextField?.text {
                self.url = NSURL(string: text)
            }
            }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func fetchImage() {
        if let url = url {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak weakSelf = self] in
                if let data = NSData(contentsOfURL: url) {
                    if url == weakSelf?.url {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let image = UIImage(data: data) {
                                weakSelf?.delegate?.setImagePicked(image)
                            }
                        }
                    }
                }
            }
        }
    }
}
