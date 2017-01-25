//
//  Options.swift
//  LessPass
//
//  Created by Dan Slupskiy on 11.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import Foundation
import SwiftyJSON

class Options: NSObject {
    var site = ""
    var login = ""
    var hasLowerCaseLetters = true
    var hasUpperCaseLetters = true
    var hasNumbers = true
    var hasSymbols = true
    var length = 16
    var counter = 1
    var version = 2
}

@objc class SavedOption: Options {
    var id: String?
    
    override init() {
        super.init()
    }
    
    init(with json:JSON) {
        id = json["id"].string!
        
        super.init()
        
        counter = json["counter"].int!
        length = json["length"].int!
        login = json["login"].string!
        hasLowerCaseLetters = json["lowercase"].bool!
        hasUpperCaseLetters = json["uppercase"].bool!
        hasNumbers = json["numbers"].bool!
        hasSymbols = json["symbols"].bool!
        site = json["site"].string!
        version = json["version"].int!
    }
}
