//
//  LoginViewController.swift
//  LessPass
//
//  Created by Daniel Slupskiy on 16.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import UIKit
import SCLAlertView

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didLaterPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func signIn(_ sender: Any) {
        if !checkFields() { return }
        
        API.requestToken(withEmail: emailTextBox.text!, andPassword: passwordTextBox.text!, onSuccess: { _ in
            SCLAlertView().showSuccess("Succeed", subTitle: "Now you have access to saved passwords").setDismissBlock {
                self.dismiss(animated: true, completion: nil)
            }
        }, onFailure: { _ in
            SCLAlertView().showError("Error", subTitle: "Check your email and password")
        })
    }
    func checkFields() -> Bool {
        guard !emailTextBox.text!.isEmpty else {
            showFieldMissedAlert(for: "email")
            return false
        }
        guard !passwordTextBox.text!.isEmpty else {
            showFieldMissedAlert(for: "password")
            return false
        }
        return true
    }
}
