//
//  ReminderViewController.swift
//  DrawIt
//
//  Created by Kristen on 6/5/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit
import NotificationCenter

class ReminderViewController: UIViewController {

    private var date: NSDate?
    
    @IBAction func setDate(sender: UIDatePicker) {
        date = sender.date
    }
    
    @IBAction func setReminder() {
        if let date = date {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = date
            localNotification.alertBody = "Reminder to draw!"
            localNotification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            
            let formatter = NSDateFormatter();
            formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a";
            let timeString = formatter.stringFromDate(date);
            
            let alert = UIAlertController(title: "Reminder to draw has been set!", message: "You will be notified on \(timeString).", preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { [unowned self] action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
}
