//
//  Json.swift
//  userTableView
//
//  Created by Gor on 12/31/20.
//

import Foundation

struct Json : Codable {
    let results : [User]
    let info : Info?
}

struct User : Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id?.value == rhs.id?.value &&
               lhs.name?.first == rhs.name?.first &&
               lhs.name?.last == rhs.name?.last &&
               lhs.email == rhs.email &&
               lhs.phone == rhs.phone
    }
    
    let gender : String?
    let name : Name?
    let location : Location?
    let email : String?
    let login : Login?
    let dob : Dob?
    let registered : Registered?
    let phone : String?
    let cell : String?
    let id : Id?
    let picture : Picture?
    let nat : String?
}

struct Info: Codable {
    let seed : String?
    let results : Int?
    let page : Int?
    let version : String?
}

struct Name : Codable {
    let title: String?
    let first : String?
    let last : String?
}

struct Location : Codable {
    let street : Street?
    let city : String?
    let state : String?
    let country : String?
    let postcode : String?
    let coordinates : Coordinates?
    let timezone : Timezone?
    
    struct Street: Codable {
        let number : Int?
        let name : String?
    }
    struct Coordinates: Codable {
        let latitude : String?
        let longitude : String?
    }
    struct Timezone : Codable {
        let offset : String?
        let description : String?
    }
    
    enum CodingKeys: String, CodingKey {
        case street
        case city
        case state
        case country
        case postcode
        case coordinates
        case timezone
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let street = try container.decode(Street.self, forKey: .street)
        let city = try container.decode(String.self, forKey: .city)
        let state = try container.decode(String.self, forKey: .state)
        let country = try container.decode(String.self, forKey: .country)
        let coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
        let timezone = try container.decode(Timezone.self, forKey: .timezone)
        
        let postcodeString = try? container.decode(String.self, forKey: .postcode)
        let postcodeInt = try? container.decode(Int.self, forKey: .postcode)
        
        self.postcode = postcodeString ?? String(postcodeInt!)
        self.street = street
        self.city = city
        self.state = state
        self.country = country
        self.coordinates = coordinates
        self.timezone = timezone
        
    }
    
}

struct Login: Codable{
    let uuid : String?
    let username : String?
    let password : String?
    let salt : String?
    let md5 : String?
    let sha1 : String?
    let sha256 : String?
}

struct Dob: Codable {
    let date : String?
    let age : Int?
}

struct Registered : Codable {
    let date : String?
    let age : Int?
}

struct Id : Codable {
    let name : String?
    let value : String?
}

struct Picture : Codable {
    let large : URL?
    let medium : URL?
    let thumbnail : URL?
}
