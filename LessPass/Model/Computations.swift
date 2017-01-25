//
//  Computations.swift
//  LessPass
//
//  Created by Dan Slupskiy on 11.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import Foundation
import CryptoSwift

extension Password {
    
    static func calculateValue(withLesspassData data:LesspassData, andTemplate template:Template) -> String {
        
        let entropy = Password.calculateEntropy(withLesspassData: data, andTemplate: template)
        let rules = Password.getConfiguredRules(withTemplate: template)
        let setOfCharacters = Password.getSetOfCharacters(fromRules: rules)
        let password = Password.consumeEntropy(withGeneratedPassword: "", quotient: Bignum(hex: entropy), setOfCharacters: setOfCharacters, andMaxLength: template.length - rules.count)
        let charactersToAdd = Password.getOneCharPerRule(withEntropy: password.entropy, andRules: rules)
        let result = Password.insertStringPseudoRandomly(charactersToAdd.value, inGeneratedPassword: password.value, withEntropy: charactersToAdd.entropy)
        
        return result
    }
    
    fileprivate struct Constants {
        static let lowercase = "lowercase"
        static let uppercase = "uppercase"
        static let numbers = "numbers"
        static let symbols = "symbols"
        static let characterSubsets = ["lowercase" : "abcdefghijklmnopqrstuvwxyz",
                                       "uppercase" : "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                                       "numbers" : "0123456789",
                                       "symbols" : "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"]
    }
    
    fileprivate static func calculateEntropy(withLesspassData lesspassData:LesspassData, andTemplate template:Template) -> String {
        var salt = lesspassData.site + lesspassData.login
        
        if template.counter < 16 {
            salt += String(template.counter)
        } else {
            salt += String(format:"%2X", template.counter)
        }
        let result = bytesToHex(try! PKCS5.PBKDF2(password: Array(lesspassData.masterPassword.utf8), salt: Array(salt.utf8), iterations: 100000, keyLength: template.keylen, variant: .sha256).calculate())
        
        return result
    }
    
    fileprivate static func getConfiguredRules(withTemplate template:Template) -> [String] {
        var result:[String] = []
        if template.hasLowerCaseLetters { result.append(Constants.lowercase) }
        if template.hasUpperCaseLetters { result.append(Constants.uppercase) }
        if template.hasNumbers { result.append(Constants.numbers) }
        if template.hasSymbols { result.append(Constants.symbols) }
        return result
    }
    
    fileprivate static func getSetOfCharacters(fromRules rules:[String]) -> String {
        var result = ""
        if rules.count == 0 {
            result.append(Constants.characterSubsets[Constants.lowercase]!)
            result.append(Constants.characterSubsets[Constants.uppercase]!)
            result.append(Constants.characterSubsets[Constants.numbers]!)
            result.append(Constants.characterSubsets[Constants.symbols]!)
        } else {
            for key in rules {
                result.append(Constants.characterSubsets[key]!)
            }
        }
        return result
    }
    
    fileprivate static func consumeEntropy(withGeneratedPassword generatedPassword:String, quotient:Bignum, setOfCharacters:String, andMaxLength maxLength:Int) -> Password {
        if generatedPassword.characters.count >= maxLength {
            return Password(withValue: generatedPassword, andEntropy: quotient)
        }
        var newPassword = generatedPassword
        let newQuotient = quotient / Bignum(setOfCharacters.characters.count)
        let remainder = quotient % Bignum(setOfCharacters.characters.count)
        let characterIndex = setOfCharacters.index(setOfCharacters.startIndex, offsetBy: remainder.toInt()!)
        newPassword.append(setOfCharacters[characterIndex])
        return consumeEntropy(withGeneratedPassword: newPassword, quotient: newQuotient, setOfCharacters: setOfCharacters, andMaxLength: maxLength)
    }
    
    fileprivate static func getOneCharPerRule(withEntropy entropy:Bignum, andRules rules: [String]) -> OneCharPerRule {
        var oneCharPerRules = ""
        var entropy = entropy
        for rule in rules {
            let password = consumeEntropy(withGeneratedPassword: "", quotient: entropy, setOfCharacters: Constants.characterSubsets[rule]!, andMaxLength: 1)
            oneCharPerRules += password.value
            entropy = password.entropy
        }
        return OneCharPerRule(withValue: oneCharPerRules, andEntropy: entropy)
    }
    
    fileprivate static func insertStringPseudoRandomly(_ string:String, inGeneratedPassword generatedPassword:String, withEntropy entropy:Bignum) -> String {
        var generatedPassword = generatedPassword
        var entropy = entropy
        for char in string.characters {
            let quotient = entropy / Bignum(generatedPassword.characters.count)
            let remainder = entropy % Bignum(generatedPassword.characters.count)
            
            let index = generatedPassword.index(generatedPassword.startIndex, offsetBy: remainder.toInt()!)
            generatedPassword = generatedPassword.substring(to: index) + String(char) + generatedPassword.substring(from: index)
            entropy = quotient
        }
        return generatedPassword
    }
    
    fileprivate static func bytesToHex(_ bytes:Array<UInt8>) -> String {
        var result = ""
        let bigInteger = Bignum(data: Data(bytes: bytes))
        result = bigInteger.asString(withBase: 16)
        let paddingLength = bytes.count*2 - result.characters.count
        if paddingLength > 0 {
            result = String(repeating: "0", count: paddingLength) + result
        }
        return result
    }
}
