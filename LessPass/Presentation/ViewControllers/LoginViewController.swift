//
//  LoginViewController.swift
//  LessPass
//
//  Created by Daniel Slupskiy on 16.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doLaterPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
