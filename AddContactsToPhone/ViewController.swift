//
//  ViewController.swift
//  AddContactsToPhone
//
//  Created by Simranpreet Chahal on 2018-01-25.
//  Copyright © 2018 Simranpreet Chahal. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

struct CustomContact {
    let contactName : String?
    let emailAddresses : [String]?
    let phoneNumbers : [String]?

    init(contactName: String? = "",emailAddresses:[String]? = [], phoneNumbers :[String]? = []) {
        self.contactName = contactName
        self.emailAddresses = emailAddresses
        self.phoneNumbers = phoneNumbers
    }

}
class ViewController: UIViewController {
    var store = CNContactStore()
    var contacts = [CustomContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestContactsPermissions({(accessGranted) -> Void in
            //do nothing
        })
    }

    func requestContactsPermissions(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
        case .denied, .notDetermined:
            self.store.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, _) -> Void in
                    completionHandler(access)})
        default:
            completionHandler(false)
        }
    }
    
    func createCustomContacts() {
        for contact in contacts {
            let newContact = CNMutableContact()
            
            if contact.contactName != "" {
                newContact.givenName = contact.contactName!
            }
            
            if let emailAddresses = contact.emailAddresses, !emailAddresses.isEmpty {
                newContact.emailAddresses = emailAddresses.map({ return CNLabeledValue(label: CNLabelHome, value:NSString(string:$0))})
            }
            
            if let phoneNumbers = contact.phoneNumbers , !phoneNumbers.isEmpty{
                newContact.phoneNumbers = phoneNumbers.map({ return CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue: $0))})
            }

            do {
                let newContactRequest = CNSaveRequest()
                newContactRequest.add(newContact, toContainerWithIdentifier: store.defaultContainerIdentifier())
                try store.execute(newContactRequest)
            } catch { print("Error in save")}
        }
    }
    
    func getDummyCustomContacts() -> [CustomContact] {
        let contact1: CustomContact = CustomContact(emailAddresses: ["email1@address.com"], phoneNumbers: ["999-989-9876"])
        
        let contact2 : CustomContact = CustomContact(phoneNumbers: ["999-989-4532"])

        let contact3 : CustomContact = CustomContact(contactName: "Turanga Leela", emailAddresses: ["tleela@planetexpress.com"], phoneNumbers: ["999-989-4532"])
        
        let contact4 : CustomContact = CustomContact(emailAddresses: ["email2@address.com"])

        let contact5 : CustomContact = CustomContact(emailAddresses: ["email3@address.com"])

        return [contact1, contact2,contact3,contact4, contact5]
    }
    
    func deleteAllContacts() {
            let predicate: NSPredicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())
            let keysToFetch = [CNContactGivenNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
            do {
                let cnContacts =  try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                guard cnContacts.count > 0 else {
                    print("no contacts found")
                    return
                }
                for contact in cnContacts {
                    let req = CNSaveRequest()
                    let mutableContact = contact.mutableCopy() as! CNMutableContact
                    req.delete(mutableContact)
                    
                    do { try store.execute(req)}
                    catch {print("delete failed")}
                }
            } catch {print("can't fetch contacts")}

        
    }
    
    @IBAction func populateContacts(_ sender: Any) {
        contacts = getDummyCustomContacts()
        let actionSheet = UIAlertController(title: "Add custom records into contacts?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Yes,please", style: .default, handler: {(action) in
            self.createCustomContacts()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            //automatically done
        }))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func deleteContacts(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Remove all Contacts?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
            self.deleteAllContacts()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "No way", style: .cancel, handler: {(action) in
            //automatically done
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

