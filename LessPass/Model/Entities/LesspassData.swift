//
//  LesspassData.swift
//  LessPass
//
//  Created by Dan Slupskiy on 11.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import Foundation

class LesspassData{
    var site:String
    var login:String
    var masterPassword:String
    
    init(withSite site:String, login:String, andMasterPassword masterPassword:String) {
        self.site = site
        self.login = login
        self.masterPassword = masterPassword
    }
}
