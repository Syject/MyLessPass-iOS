//
//  OneCharPerRule.swift
//  LessPass
//
//  Created by Dan Slupskiy on 11.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import Foundation

class OneCharPerRule {
    var value = ""
    var entropy = Bignum()
    
    init(withValue value:String, andEntropy entropy:Bignum) {
        self.value = value
        self.entropy = entropy
    }
}
