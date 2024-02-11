//
//  Users.swift
//  FoursquareClone
//
//  Created by İlhan Cüvelek on 3.02.2024.
//

import Foundation

class Users{
    
    var userId:String
    var username:String
    var email:String
    var password:String

    init(userId: String, username: String, email: String, password: String) {
        self.userId = userId
        self.username = username
        self.email = email
        self.password = password
    }
}
