//
//  User.swift
//  Microcad
//
//  Created by Pradeep Chandrasekaran on 01/02/19.
//  Copyright © 2019 Pradeep Chandrasekaran. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {

    var userName: String!
    var userEmail: String!
    var userPhone: String!
    var userLocation: String!
    
    init(userName: String, userEmail: String, userPhone: String, userLocation: String) {
        
        self.userName = userName
        self.userEmail = userEmail
        self.userPhone = userPhone
        self.userLocation = userLocation

        
    }

    override init() {
        
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        userName = aDecoder.decodeObject(forKey: "userName") as? String
        userEmail = aDecoder.decodeObject(forKey: "userEmail") as? String
        userPhone = aDecoder.decodeObject(forKey: "userPhone") as? String
        userLocation = aDecoder.decodeObject(forKey: "userLocation") as? String

    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(userEmail, forKey: "userEmail")
        aCoder.encode(userPhone, forKey: "userPhone")
        aCoder.encode(userLocation, forKey: "userLocation")
        
    }
    
}
