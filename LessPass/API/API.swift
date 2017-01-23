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
typealias FailureBlock = (_ error: Error)->()

class API {
    struct Constants {
        struct URLs {
            static let base = "https://lesspass.com/"
            
            static let requestToken = "\(base)api/tokens/auth/"
            
            static let refresh = "\(base)api/tokens/refresh/"
            
            static let register = "\(base)api/auth/register/"
            
            static let options = "\(base)api/passwords/"
        }
    }
    static private var token: String?
    
    static var isUserAuthorized: Bool {
        return token != nil
    }
    
    static func requestToken(withEmail email: String, andPassword password: String, onSuccess successBlock:@escaping TokenSuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        
        Alamofire.request(Constants.URLs.requestToken,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(_):
                guard let data = response.data else { print("Request returned no data"); return }
                let json = JSON(data: data)
                debugPrint(json)
                guard let token = json["token"].string else { print("Couldn't receive token");return }
                self.token = token
                successBlock(token)
            case .failure(let error):
                failureBlock(error)
            }
        }
    }
    
    static func getAllOptions(onSuccess successBlock: @escaping OptionsSuccessBlock, onFailure failureBlock:@escaping FailureBlock) {
        guard let token = token else { print("No token"); return }
        let headers: HTTPHeaders = [ "Authorization": "JWT \(token)" ]
        Alamofire.request(Constants.URLs.options,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: headers).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var savedOptions = [SavedOption]()
                for jsonData in json["results"].array! {
                    let savedOption = SavedOption(with: jsonData)
                    savedOptions.append(savedOption)
                }
                successBlock(savedOptions)
            case .failure(let error):
                failureBlock(error)
                print(error)
            }
        })
    }
}
