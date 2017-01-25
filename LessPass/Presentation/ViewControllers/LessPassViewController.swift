//
//  LessPassViewController.swift
//  LessPass UI
//
//  Created by Daniel Slupskiy on 14.01.17.
//  Copyright © 2017 Daniel Slupskiy. All rights reserved.
//

import UIKit
import BEMCheckBox
import SCLAlertView
import Alamofire
import SwiftyJSON

class LessPassViewController: UIViewController, BEMCheckBoxDelegate {
    
    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var masterPasswordTextField: UITextField!
    
    @IBOutlet weak var lowerCheckBox: BEMCheckBox!
    @IBOutlet weak var upperCheckBox: BEMCheckBox!
    @IBOutlet weak var numbersCheckBox: BEMCheckBox!
    @IBOutlet weak var symbolsCheckBox: BEMCheckBox!
    
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var counterTextField: UITextField!
    
    private var waitAlertResponder:SCLAlertViewResponder?
    static private var isFirstTimeLauched:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if LessPassViewController.isFirstTimeLauched {
            switchToMaster()
            SCLAlertView().showEdit("123", subTitle: "123")
            LessPassViewController.isFirstTimeLauched = false
        }
        
        doUIPreparations()
        
        setDefaultValues()
    }
    
    func setDefaultValues() {
        siteTextField.text = UserDefaults.standard.string(forKey: "siteTextField")
        loginTextField.text = UserDefaults.standard.string(forKey: "loginTextField")
        masterPasswordTextField.text = UserDefaults.standard.string(forKey: "masterPasswordTextField")
        
        lowerCheckBox.on = !UserDefaults.standard.bool(forKey: "lowerCheckBox")
        upperCheckBox.on = !UserDefaults.standard.bool(forKey: "upperCheckBox")
        numbersCheckBox.on = !UserDefaults.standard.bool(forKey: "numbersCheckBox")
        symbolsCheckBox.on = !UserDefaults.standard.bool(forKey: "symbolsCheckBox")
        
        lengthTextField.text = UserDefaults.standard.string(forKey: "lengthTextField") ?? "16"
        counterTextField.text = UserDefaults.standard.string(forKey: "counterTextField") ?? "1"
    }
    
    func switchToMaster() {
        if let splitViewController = splitViewController {
            if splitViewController.isCollapsed {
                let detailNavigationController = parent as! UINavigationController
                let masterNavigationController = detailNavigationController.parent as! UINavigationController
                masterNavigationController.popToRootViewController(animated: false)
            }
        }
    }

    @IBAction func generateDidPressed(_ sender: Any) {
        self.view.endEditing(true)
        if !checkFields() {
            return
        }
        let site = siteTextField.text!
        let login = loginTextField.text!
        let masterPassword = masterPasswordTextField.text!
        let length = Int(lengthTextField.text!)!
        let counter = Int(counterTextField.text!)!
        
        let template = Template()
        template.hasLowerCaseLetters = lowerCheckBox.on
        template.hasUpperCaseLetters = upperCheckBox.on
        template.hasNumbers = numbersCheckBox.on
        template.hasSymbols = symbolsCheckBox.on
        template.length = length
        template.counter = counter
        
        let data = LesspassData(withSite: site, login: login, andMasterPassword: masterPassword)
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            showCircularIcon: true
        )
        waitAlertResponder = SCLAlertView(appearance: appearance).showWait("Please wait...", subTitle: "Some magic is happening...", colorStyle: 0x1477D4)
        print("waitAlert showed!")
        DispatchQueue.global(qos: .userInteractive).async {
            let passwordValue = Password.calculateValue(withLesspassData: data, andTemplate: template)
            DispatchQueue.main.async {
                self.waitAlertResponder?.close()
                
                let successAlert = SCLAlertView()
                successAlert.addButton("Copy", action: {
                    UIPasteboard.general.string = passwordValue
                })
                successAlert.showSuccess("Here you are",
                                         subTitle: "Your password is \n\(passwordValue)\nThis alert will be closed after 30 seconds", duration: 30)
            }
        }
        
    }
    @IBAction func asDefaultDidPressed(_ sender: Any) {
        UserDefaults.standard.set(siteTextField.text, forKey: "siteTextField")
        UserDefaults.standard.set(loginTextField.text, forKey: "loginTextField")
        UserDefaults.standard.set(masterPasswordTextField.text, forKey: "masterPasswordTextField")
        
        UserDefaults.standard.set(!lowerCheckBox.on, forKey: "lowerCheckBox")
        UserDefaults.standard.set(!upperCheckBox.on, forKey: "upperCheckBox")
        UserDefaults.standard.set(!numbersCheckBox.on, forKey: "numbersCheckBox")
        UserDefaults.standard.set(!symbolsCheckBox.on, forKey: "symbolsCheckBox")
        
        UserDefaults.standard.set(lengthTextField.text, forKey: "lengthTextField")
        UserDefaults.standard.set(counterTextField.text, forKey: "counterTextField")
    }
    
    @IBAction func saveDidPressed(_ sender: Any) {
        guard API.isUserAuthorized else { SCLAlertView().showError("Error", subTitle: "You need to log in"); return }
        guard checkFields() else { return }
        
        let options = Options()
        options.site = siteTextField.text!
        options.login = loginTextField.text!
        options.length = Int(lengthTextField.text!)!
        options.counter = Int(counterTextField.text!)!
        options.hasLowerCaseLetters = !lowerCheckBox.on
        options.hasUpperCaseLetters = !upperCheckBox.on
        options.hasNumbers = !numbersCheckBox.on
        options.hasSymbols = !symbolsCheckBox.on
        
        API.saveOptions(options, onSuccess: {}, onFailure: {_ in})
    }
    
    @IBAction func lengthValueChanged(_ sender: UIStepper) {
        lengthTextField.text = String(Int(sender.value))
    }
    
    @IBAction func counterValueChanged(_ sender: UIStepper) {
        counterTextField.text = String(Int(sender.value))
    }
    
    // MARK: BEMCheckBoxDelegate
    func didTap(_ checkBox: BEMCheckBox) {
        if !lowerCheckBox.on &&
            !upperCheckBox.on &&
            !numbersCheckBox.on &&
            !symbolsCheckBox.on {
            lowerCheckBox.on = true
            upperCheckBox.on = true
            numbersCheckBox.on = true
            symbolsCheckBox.on = true
        }
    }
    
    // MARK: UI Setup
    func doUIPreparations() {
        // Checkboxes
        lowerCheckBox.delegate = self
        UIPreparation.configurateStyleOf(checkBox: lowerCheckBox)
        upperCheckBox.delegate = self
        UIPreparation.configurateStyleOf(checkBox: upperCheckBox)
        numbersCheckBox.delegate = self
        UIPreparation.configurateStyleOf(checkBox: numbersCheckBox)
        symbolsCheckBox.delegate = self
        UIPreparation.configurateStyleOf(checkBox: symbolsCheckBox)
    }
    
    func checkFields() -> Bool {
        guard !siteTextField.text!.isEmpty else { showFieldMissedAlert(for: "site"); return false }
        guard !loginTextField.text!.isEmpty else { showFieldMissedAlert(for: "login"); return false }
        guard !masterPasswordTextField.text!.isEmpty else { showFieldMissedAlert(for: "master password"); return false }
        return true
    }
}
