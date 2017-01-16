//
//  Constants.swift
//  LessPass
//
//  Created by Dan Slupskiy on 16.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import UIKit
import FlatUIKit
import BEMCheckBox
import SCLAlertView

extension UIColor {
    struct LesspassColors {
        struct v2 {
            static let mainColor = UIColor(red: 20/255.0, green: 119/255.0, blue: 212/255.0, alpha: 1.0)
        }
    }
}

extension UIViewController {
    struct UIPreparation {
        static func configurateStyleOf(checkBox:BEMCheckBox) {
            checkBox.boxType = .square
        }
        static func configurateStyleOf(button:FUIButton) {
            button.buttonColor = UIColor.LesspassColors.v2.mainColor
            button.highlightedColor = UIColor.LesspassColors.v2.mainColor
            button.shadowColor = UIColor.black
            button.shadowHeight = 3.0
            button.cornerRadius = 6.0
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        }
    }
    func showFieldMissedAlert(for fieldName:String) {
        SCLAlertView().showError("Field is missed", subTitle: "You can't leave \(fieldName) empty")
    }
}

