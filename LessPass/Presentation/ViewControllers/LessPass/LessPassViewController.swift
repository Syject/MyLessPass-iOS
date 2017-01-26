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
    
    @IBOutlet fileprivate weak var siteTextField: UITextField!
    @IBOutlet fileprivate weak var loginTextField: UITextField!
    @IBOutlet fileprivate weak var masterPasswordTextField: UITextField!
    
    @IBOutlet fileprivate weak var lowerCheckBox: BEMCheckBox!
    @IBOutlet fileprivate weak var upperCheckBox: BEMCheckBox!
    @IBOutlet fileprivate weak var numbersCheckBox: BEMCheckBox!
    @IBOutlet fileprivate weak var symbolsCheckBox: BEMCheckBox!
    
    @IBOutlet fileprivate weak var lengthTextField: UITextField!
    @IBOutlet fileprivate weak var counterTextField: UITextField!
    
    fileprivate var waitAlertResponder:SCLAlertViewResponder?
    static fileprivate var isFirstTimeLauched:Bool = true
    
    var choosedSavedOption: SavedOption?
    var delegate: LessPassViewControllerDelegate?
    
    internal override func viewDidLoad() {
        super.viewDidLoad()

        if LessPassViewController.isFirstTimeLauched {
            switchToMaster()
            LessPassViewController.isFirstTimeLauched = false
        }
        
        doUIPreparations()
        
        setDefaultValues()
    }
    
    fileprivate func setDefaultValues() {
        siteTextField.text = choosedSavedOption?.site
            ?? UserDefaults.standard.string(forKey: "siteTextField")
        loginTextField.text = choosedSavedOption?.login
            ?? UserDefaults.standard.string(forKey: "loginTextField")
        
        lowerCheckBox.on = choosedSavedOption?.hasLowerCaseLetters
            ?? !UserDefaults.standard.bool(forKey: "lowerCheckBox")
        upperCheckBox.on = choosedSavedOption?.hasUpperCaseLetters
            ?? !UserDefaults.standard.bool(forKey: "upperCheckBox")
        numbersCheckBox.on = choosedSavedOption?.hasNumbers
            ?? !UserDefaults.standard.bool(forKey: "numbersCheckBox")
        symbolsCheckBox.on = choosedSavedOption?.hasSymbols
            ?? !UserDefaults.standard.bool(forKey: "symbolsCheckBox")
        
        if let length = choosedSavedOption?.length {
            lengthTextField.text = "\(length)"
        } else {
            lengthTextField.text = UserDefaults.standard.string(forKey: "lengthTextField")
                ?? "16"
        }
        
        if let counter = choosedSavedOption?.counter {
            counterTextField.text = "\(counter)"
        } else {
            counterTextField.text = UserDefaults.standard.string(forKey: "counterTextField")
                ?? "1"
        }
        
        
    }
    
    fileprivate func switchToMaster() {
        if let splitViewController = splitViewController {
            if splitViewController.isCollapsed {
                let detailNavigationController = parent as! UINavigationController
                let masterNavigationController = detailNavigationController.parent as! UINavigationController
                masterNavigationController.popToRootViewController(animated: false)
            }
        }
    }

    @IBAction fileprivate func generateDidPressed(_ sender: Any) {
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
    @IBAction fileprivate func asDefaultDidPressed(_ sender: Any) {
        UserDefaults.standard.set(siteTextField.text, forKey: "siteTextField")
        UserDefaults.standard.set(loginTextField.text, forKey: "loginTextField")
       
        UserDefaults.standard.set(!lowerCheckBox.on, forKey: "lowerCheckBox")
        UserDefaults.standard.set(!upperCheckBox.on, forKey: "upperCheckBox")
        UserDefaults.standard.set(!numbersCheckBox.on, forKey: "numbersCheckBox")
        UserDefaults.standard.set(!symbolsCheckBox.on, forKey: "symbolsCheckBox")
        
        UserDefaults.standard.set(lengthTextField.text, forKey: "lengthTextField")
        UserDefaults.standard.set(counterTextField.text, forKey: "counterTextField")
    }
    
    @IBAction fileprivate func saveDidPressed(_ sender: Any) {
        guard API.isUserAuthorized else { SCLAlertView().showError("Error", subTitle: "You need to log in"); return }
        guard checkFields() else { return }
        
        let options = SavedOption()
        options.site = siteTextField.text!
        options.login = loginTextField.text!
        options.length = Int(lengthTextField.text!)!
        options.counter = Int(counterTextField.text!)!
        options.hasLowerCaseLetters = lowerCheckBox.on
        options.hasUpperCaseLetters = upperCheckBox.on
        options.hasNumbers = numbersCheckBox.on
        options.hasSymbols = symbolsCheckBox.on
        options.id = choosedSavedOption?.id
        
        API.saveOptions(options, onSuccess: { [unowned self] in
            self.delegate?.getSitesList()
        }, onFailure: {error in
            DispatchQueue.main.async {
                SCLAlertView().showError("Error", subTitle: error)
            }
        })
    }
    
    @IBAction fileprivate func lengthValueChanged(_ sender: UIStepper) {
        lengthTextField.text = String(Int(sender.value))
    }
    
    @IBAction fileprivate func counterValueChanged(_ sender: UIStepper) {
        counterTextField.text = String(Int(sender.value))
    }
    
    // MARK: BEMCheckBoxDelegate
    internal func didTap(_ checkBox: BEMCheckBox) {
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
    fileprivate func doUIPreparations() {
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
    
    fileprivate func checkFields() -> Bool {
        guard !siteTextField.text!.isEmpty else { showFieldMissedAlert(for: "site"); return false }
        guard !loginTextField.text!.isEmpty else { showFieldMissedAlert(for: "login"); return false }
        guard !masterPasswordTextField.text!.isEmpty else { showFieldMissedAlert(for: "master password"); return false }
        return true
    }
}
