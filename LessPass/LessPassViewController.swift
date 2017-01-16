//
//  LessPassViewController.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 14.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit
import BEMCheckBox
import FlatUIKit

class LessPassViewController: UIViewController {
    
    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var masterPasswordTextField: UITextField!
    
    @IBOutlet weak var lowerCheckBox: BEMCheckBox!
    @IBOutlet weak var upperCheckBox: BEMCheckBox!
    @IBOutlet weak var numbersCheckBox: BEMCheckBox!
    @IBOutlet weak var symbolsCheckBox: BEMCheckBox!
    
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var counterTextField: UITextField!
    
    @IBOutlet weak var generateButton: FUIButton!
    @IBOutlet weak var saveDefaultButton: FUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doUIPreparations()
        
    }

    @IBAction func generateDidPressed(_ sender: Any) {
        if !checkFields() {
            return
        }
        /*
        let site = siteTextField.text

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
 */

    }
    
    @IBAction func lengthValueChanged(_ sender: UIStepper) {
        lengthTextField.text = String(Int(sender.value))
    }
    
    @IBAction func counterValueChanged(_ sender: UIStepper) {
        counterTextField.text = String(Int(sender.value))
    }
    
    // MARK: UI Setup
    func doUIPreparations() {
        // Checkboxes
        UIPreparation.configurateStyleOf(checkBox: lowerCheckBox)
        UIPreparation.configurateStyleOf(checkBox: upperCheckBox)
        UIPreparation.configurateStyleOf(checkBox: numbersCheckBox)
        UIPreparation.configurateStyleOf(checkBox: symbolsCheckBox)
        
        // Buttons
        UIPreparation.configurateStyleOf(button: generateButton)
        UIPreparation.configurateStyleOf(button: saveDefaultButton)
    }
    
    func checkFields() -> Bool {
        guard !siteTextField.text!.isEmpty else {
            showFieldMissedAlert(for: "site")
            return false
        }
        guard !loginTextField.text!.isEmpty else {
            showFieldMissedAlert(for: "login")
            return false
        }
        guard !masterPasswordTextField.text!.isEmpty else {
            showFieldMissedAlert(for: "master password")
            return false
        }
        return true
    }
}
