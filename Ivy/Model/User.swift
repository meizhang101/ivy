//
//  User.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21. meizhang@usc.edu
//

import Foundation
import Firebase
import CodableFirebase

// https://github.com/alickbass/CodableFirebase
class User: Codable {
    
    var uid: String?
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: Int
    var journal: [Entry]?
    
    
    // userID is initially optional, because when we retrieve the user the first time they may not have a userID initialized yet
    init(uid: String? = nil, firstName: String, lastName: String, email: String, phoneNumber: Int, journal: [Entry]? = nil) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.journal = journal
    }
    
    // function that updates the fields and writes them to FireStore
    func writeToFirestore() {
        let docData = try! FirestoreEncoder().encode(self)
        Firestore.firestore().collection("users").document(uid!).setData(docData, merge: true) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // adds entry to the journal
    func addEntry(entry: Entry) {
        if journal == nil {
            journal = [Entry]()
        }
        journal?.append(entry)
        writeToFirestore()
    }
 
}
