//
//  SavedOption.swift
//  LessPass
//
//  Created by Dan Slupskiy on 23.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc class SavedOption: NSObject {
    let counter: Int
    let created: String
    let id: String
    let length: Int
    let login: String
    let lowercase: Bool
    let uppercase: Bool
    let numbers: Bool
    let symbols: Bool
    let modified: String
    let site: String
    let version: Int

    init(with json:JSON) {
        counter = json["counter"].int!
        created = json["created"].string!
        id = json["id"].string!
        length = json["length"].int!
        login = json["login"].string!
        lowercase = json["lowercase"].bool!
        uppercase = json["uppercase"].bool!
        numbers = json["numbers"].bool!
        symbols = json["symbols"].bool!
        modified = json["modified"].string!
        site = json["site"].string!
        version = json["version"].int!
    }
}
