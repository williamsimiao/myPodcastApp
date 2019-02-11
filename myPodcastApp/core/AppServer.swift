//
//  AppServer.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

import UIKit

open class AppServer {
    
    let urlApi:String = AppConfig.urlBaseApi + "controller.php"
    
    let authLogin:String = "546c3449aae479a57edee2bf0b660e03"
    let authPasswd:String = "midiabox"
    
    
    func send(_ method: String, data: NSDictionary? = nil) -> NSDictionary? {
        
        //if (!checkConnection()) {
        //   return nil
        //}
        
        let dataAuth = NSMutableDictionary()
        
        dataAuth["login"] = self.authLogin
        dataAuth["passwd"] = self.authPasswd
        
        
        let dataSend = NSMutableDictionary()
        
        dataSend["auth"] = dataAuth
        dataSend["method"] = method
        
        dataSend["data"] = ""
        
        if let data = data {
            dataSend["data"] = data
        }
        
        let response = self.requestApi(self.urlApi, dataSend: dataSend, key: "")
        
        return response
    }
    
    fileprivate func requestApi(_ url: String, dataSend: NSDictionary, key: String, needDescrypt: Bool = true) -> NSDictionary? {
        
        print(url)
        
        var output: NSDictionary?
        
        let encrypt = AppService.util.encodeJson(dataSend) //AppService.util.encryptAES(AppService.util.encodeJson(dataSend), rawKey: key)
        
        let URL: Foundation.URL = Foundation.URL(string: url)!
        
        let bodyData = encrypt //"data=" + encrypt + "&hash=" + AppService.user.hash_device!
        
        NSLog("bodyData %@", bodyData)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL)
        
        request.httpMethod = "POST"
        request.httpBody = bodyData.data(using: String.Encoding.utf8)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        /*var response: URLResponse?
         let responseData: Data?
         
         do {
         responseData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response)
         
         print("responseData")
         dump(responseData)
         
         } catch _ {
         print("catch")
         
         return nil
         }
         
         if let response = response as? HTTPURLResponse, let responseData = responseData {
         
         do {
         
         if (response.statusCode == 200) {
         
         output = try AppService.util.decodeJsonFromString(String(describing: responseData))
         
         if needDescrypt {
         output = try AppService.util.decodeJsonFromString(AppService.util.decryptAES(responseData.toString(), rawKey: key))
         } else {
         output = try AppService.util.decodeJsonFromString(responseData.toString())
         }
         
         } else if (response.statusCode == 400) {
         output = try AppService.util.decodeJsonFromString(String(describing: responseData))
         } else {
         output = try AppService.util.decodeJsonFromString(String(describing: responseData))
         }
         
         } catch _ {
         return nil
         }
         
         }*/
        
        return output
    }
    
}
