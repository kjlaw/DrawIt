//
//  ContactsTableViewController.swift
//  DrawIt
//
//  Created by Kristen on 6/5/16.
//  Copyright © 2016 Kristen Law. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ContactsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {
    
    var snapshotImage: UIImage?
    
    // adapted from http://stackoverflow.com/questions/32669612/how-to-fetch-all-contacts-record-in-ios-9-using-contacts-framework
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
            CNContactPhoneNumbersKey]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containersMatchingPredicate(nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                results.appendContentsOf(containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath)

        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        cell.detailTextLabel?.text = (contact.phoneNumbers.first?.value as? CNPhoneNumber)?.stringValue

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        sendMessage(cell.detailTextLabel!.text!)
    }
    
    func sendMessage(number: String) {
        let messagevc = MFMessageComposeViewController()

        messagevc.recipients = [number]
        messagevc.messageComposeDelegate = self;
        
        print(snapshotImage)
        if let image = snapshotImage {
            let attachment = UIImageJPEGRepresentation(image, 1)!
            messagevc.addAttachmentData(attachment, typeIdentifier: "image/jpeg", filename: "drawing.jpg")
        }
        
        self.presentViewController(messagevc, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func returnToPreviousView(sender: UIBarButtonItem) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
