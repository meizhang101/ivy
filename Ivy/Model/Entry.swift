//
//  Entry.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21. meizhang@usc.edu
//

import Foundation
import CodableFirebase
import Firebase

extension Timestamp: TimestampType {}

// https://developer.apple.com/documentation/foundation/dateformatter
struct Entry : Codable {
    
    let date: Timestamp
    let text: String
    let index: Int
    var photoReference: String?
    // allows one photo per day, but may change that later
    var isHidden: Bool
    
    init(text: String, isHidden: Bool = false, photoReference: String? = nil, index: Int) {
        self.date = Timestamp(date: Date())
        self.text = text
        self.isHidden = isHidden
        self.photoReference = photoReference
        self.index = index
    }
    
    // returns the date as a string, with or without time
    func getDateString(time: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if time {
            dateFormatter.timeStyle = .short
        }
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date.dateValue())
    }
   

}

