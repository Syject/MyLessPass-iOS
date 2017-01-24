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

    var delegate: LoginViewControllerDelegate?
    @IBOutlet weak var emailTextBox: UITextField!
    @IBOutlet weak var passwordTextBox: UITextField!

    @IBAction func didLaterPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func signIn(_ sender: Any) {
        if !checkFields() { return }
        
        API.requestToken(withEmail: emailTextBox.text!, andPassword: passwordTextBox.text!, onSuccess: { _ in
            SCLAlertView().showSuccess("Succeed", subTitle: "Now you have access to saved passwords").setDismissBlock {
                self.delegate?.getSitesList()
                self.dismiss(animated: true, completion: nil)
            }
        }, onFailure: { error in
            SCLAlertView().showError("Error", subTitle: error)
        })
    }
    @IBAction func register(_ sender: Any) {
        if !checkFields() { return }
        
        API.register(withEmail: emailTextBox.text!, andPassword: passwordTextBox.text!, onSuccess: { _ in
            SCLAlertView().showSuccess("Succeed", subTitle: "Now you are registered on lesspass.com").setDismissBlock {
                self.delegate?.getSitesList()
                self.dismiss(animated: true, completion: nil)
            }
        }, onFailure: { error in
            SCLAlertView().showError("Error", subTitle: error)
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
