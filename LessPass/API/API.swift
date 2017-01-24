//
//  API.swift
//  LessPass
//
//  Created by Dan Slupskiy on 23.01.17.
//  Copyright © 2017 Syject. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias TokenSuccessBlock = (_ token: String)->()
typealias OptionsSuccessBlock = (_ options: [SavedOption])->()
typealias SuccessBlock = () -> ()
typealias FailureBlock = (_ error: String)->()

class API {
    private struct Constants {
        struct URLs {
            static let base = "https://lesspass.com/"
            static let requestToken = "\(base)api/tokens/auth/"
            static let refresh = "\(base)api/tokens/refresh/"
            static let register = "\(base)api/auth/register/"
            static let options = "\(base)api/passwords/"
        }
    }
    static private var token: String?
    
    static var isUserAuthorized: Bool { return token != nil }
    
    static func unauthorizeUser(){ token = nil }
    
    static func requestToken(withEmail email: String, andPassword password: String, onSuccess successBlock:@escaping TokenSuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(Constants.URLs.requestToken,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    guard let data = response.data else { print("Request returned no data"); return }
                    let json = JSON(data: data)
                    debugPrint(json)
                    guard let token = json["token"].string else {
                        print("Couldn't receive token");
                        failureBlock(getErrorTextFromSuccessJson(json))
                        return
                    }
                    self.token = token
                    successBlock(token)
                case .failure(let error):
                    failureBlock(error.localizedDescription)
                }
        }
    }
    
    static func refreshToken(onSuccess successBlock:@escaping TokenSuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        guard let token = token else { return }
        let parameters: Parameters = [
            "token": token
        ]
        Alamofire.request(Constants.URLs.refresh,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    guard let data = response.data else { print("Request returned no data"); return }
                    let json = JSON(data: data)
                    debugPrint(json)
                    guard let token = json["token"].string else {
                        print("Couldn't receive token");
                        failureBlock(getErrorTextFromSuccessJson(json))
                        return
                    }
                    self.token = token
                    successBlock(token)
                case .failure(let error):
                    failureBlock(error.localizedDescription)
                }
        }
    }
    
    static func register(withEmail email: String, andPassword password: String, onSuccess successBlock:@escaping TokenSuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(Constants.URLs.register,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    guard let data = response.data else { print("Request returned no data"); return }
                    let json = JSON(data: data)
                    debugPrint(json)
                    
                    guard json["id"].int != nil else {
                        print("Couldn't receive token");
                        failureBlock(getErrorTextFromSuccessJson(json))
                        return
                    }
                    requestToken(withEmail: email, andPassword: password, onSuccess: successBlock, onFailure: failureBlock)
                case .failure(let error):
                    failureBlock(error.localizedDescription)
                }
        }
    }
    
    
    static func getAllOptions(onSuccess successBlock: @escaping OptionsSuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        guard let token = token else { print("No token"); return }
        let headers: HTTPHeaders = [ "Authorization": "JWT \(token)" ]
        Alamofire.request(Constants.URLs.options,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    var savedOptions = [SavedOption]()
                    for jsonData in json["results"].array! {
                        let savedOption = SavedOption(with: jsonData)
                        savedOptions.append(savedOption)
                    }
                    successBlock(savedOptions)
                case .failure(let error):
                    failureBlock(error.localizedDescription)
                    print(error)
                }
        }
    }
    
    static func saveOptions(_ options: Options, onSuccess successBlock:@escaping SuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        let parameters: Parameters = [
            "counter" : options.counter,
            "length" : options.length,
            "login" : options.login,
            "lowercase" : options.hasLowerCaseLetters,
            "uppercase" : options.hasUpperCaseLetters,
            "numbers" : options.hasNumbers,
            "symbols" : options.hasSymbols,
            "site" : options.site,
            "version" : options.version
        ]
        let headers: HTTPHeaders = [ "Authorization": "JWT \(token)" ]
        
        Alamofire.request(Constants.URLs.options,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    guard let data = response.data else { print("Request returned no data"); return }
                    let json = JSON(data: data)
                    debugPrint(json)
                case .failure(let error):
                    failureBlock(error.localizedDescription)
                }
        }
    }

    
    static func deleteOption(withId optionId:String, onSuccess successBlock:@escaping SuccessBlock, onFailure failureBlock: @escaping FailureBlock) {
        guard let token = token else { print("No token"); return }
        let headers: HTTPHeaders = [ "Authorization": "JWT \(token)" ]
        
        Alamofire.request(Constants.URLs.options + "\(optionId)/",
                          method: .delete,
                          headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    successBlock()
                case .failure(let error):
                    failureBlock(error.localizedDescription)
                    print(error)
                }
        }
    }
    
    fileprivate static func getErrorTextFromSuccessJson(_ json:JSON) -> String {
        var errorText = ""
        for (_,subJson):(String, JSON) in json {
            errorText += subJson[0].string!
        }
        return errorText
    }
    
}
