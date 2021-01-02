//
//  FileManager.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import Foundation

class UserSaver {
    
    static let shared = UserSaver()
    
    private let userURL: URL
    
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        userURL = documentsDirectory.appendingPathComponent("users").appendingPathExtension("plist")
    }
    
    func readUsers() -> [User] {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedUsersData = try? Data(contentsOf: userURL),
           let decodedUsers = try? propertyListDecoder.decode(Array<User>.self,
                                                              from: retrievedUsersData){
            return decodedUsers
        }
        return []
    }
    
    func writeUsers(_ users: [User]) {
        let propertyListEncoder = PropertyListEncoder()
        let encodedUsers = try? propertyListEncoder.encode(users)
        try? encodedUsers?.write(to: userURL, options: .noFileProtection)
    }
}
