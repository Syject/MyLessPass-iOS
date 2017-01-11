//
//  ViewController.swift
//  LessPass
//
//  Created by Dan Slupskiy on 10.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEMPORATE TEST, WILL BE REMOVED
        let site = "vk.com"
        let login = "slupdog"
        let masterPassword = "123"
        let length = 16
        let counter = 1
        
        let template = Template()
        template.hasLowerCaseLetters = true
        template.hasUpperCaseLetters = true
        template.hasNumbers = true
        template.hasSymbols = true
        template.length = length
        template.counter = counter
        
        let data = LesspassData(withSite: site, login: login, andMasterPassword: masterPassword)
        
        print("Password is : " + Password.calculateValue(withLesspassData: data, andTemplate: template))
    }
}

