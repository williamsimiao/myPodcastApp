//
//  AppUtil.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

open class AppUtil {
    
    func currentView() -> UIViewController {
        var currentViewController: UIViewController!
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            currentViewController = topController
        }
        return currentViewController
    }
    
    func isKeyPresentInUserDefaults(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func isNotNull(_ object:AnyObject?) -> Bool {
        
        if object as? String == "" {
            return false;
        }
        
        guard let object = object else {
            return false
        }
        
        return (isNotNSNull(object) && isNotStringNull(object))
    }
    
    func isNotNSNull(_ object:AnyObject) -> Bool {
        return object.classForCoder != NSNull.classForCoder()
    }
    
    func isNotStringNull(_ object:AnyObject) -> Bool {
        if let object = object as? String , object.uppercased() == "NULL" {
            return false
        }
        return true
    }
    
    func alert(_ title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{(ACTION :UIAlertAction) in
        }))
        
        self.currentView().present(alert, animated: true, completion: nil)
    }
    
    func decodeJsonFromData(_ plainData: Data) throws -> NSDictionary {
        var output: NSDictionary!
        do {
            output = try JSONSerialization.jsonObject(with: plainData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch _ {
            throw AppError.cryptError
        }
        return output
    }
    
    func decodeJsonFromString(_ plainString: String) throws -> NSDictionary {
        
        NSLog("plainString %@", plainString)
        
        let plainData = (plainString as NSString).data(using: String.Encoding.utf8.rawValue)!
        var output: NSDictionary!
        do {
            output = try JSONSerialization.jsonObject(with: plainData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch _ {
            throw AppError.cryptError
        }
        return output
    }
    
    func encodeJson(_ data: AnyObject) -> String {
        let data2 = try? JSONSerialization.data(withJSONObject: data, options: [])
        let string = NSString(data: data2!, encoding: String.Encoding.utf8.rawValue)! as String
        print(string)
        return string
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    func load_image_usuario(_ link:String, imageview:UIImageView) {
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/usuario_60_" + link;
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            
            do {
                
                imageview.image = UIImage(contentsOfFile: filePath)
                
            }
            
        } else {
            
            let url_foto:String = AppConfig.urlBaseThumb + "src=/images/" + link + "&w=120&h=120&zc=1"
            
            print(url_foto)
            
            let url:URL = URL(string: url_foto)!
            let session = URLSession.shared
            
            var request = URLRequest(url: url)
            
            request.timeoutInterval = 10
            
            
            let task = session.dataTask(with: request, completionHandler: {
                (
                data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    return
                }
                
                
                if let image = UIImage(data: data!) {
                    
                    // salvar no disco
                    DispatchQueue.main.async(execute: {
                        try? data?.write(to: URL(fileURLWithPath: filePath), options: [.atomic]);
                    })
                    
                    
                    DispatchQueue.main.async(execute: {
                        do {
                            imageview.image = image
                        }
                    })
                    
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
    func load_image_oferta(_ link:String, cod_oferta:String, imageview:UIImageView) {
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/oferta_" + cod_oferta + "_150";
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            
            do {
                
                imageview.image = UIImage(contentsOfFile: filePath)
                
            }
            
        } else {
            
            let url_foto:String = link //AppConfig.urlBaseThumb + "src=/images/posts/" + cod_post + "/" + link + "&w=600&zc=1"
            
            print("link " + url_foto)
            
            let url:URL = URL(string: url_foto)!
            let session = URLSession.shared
            
            var request = URLRequest(url: url)
            
            request.timeoutInterval = 10
            
            
            let task = session.dataTask(with: request, completionHandler: {
                (
                data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    return
                }
                
                
                if let image = UIImage(data: data!) {
                    
                    // salvar no disco
                    DispatchQueue.main.async(execute: {
                        try? data?.write(to: URL(fileURLWithPath: filePath), options: [.atomic]);
                    })
                    
                    
                    DispatchQueue.main.async(execute: {
                        do {
                            imageview.image = image
                        }
                    })
                    
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
    func load_image_empresa(_ link:String, cod_empresa:String, imageview:UIImageView) {
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/empresa_" + cod_empresa + "_150";
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            
            do {
                
                imageview.image = UIImage(contentsOfFile: filePath)
                
            }
            
        } else {
            
            let url_foto:String = link //AppConfig.urlBaseThumb + "src=/images/posts/" + cod_post + "/" + link + "&w=600&zc=1"
            
            print("link " + url_foto)
            
            let url:URL = URL(string: url_foto)!
            let session = URLSession.shared
            
            var request = URLRequest(url: url)
            
            request.timeoutInterval = 10
            
            
            let task = session.dataTask(with: request, completionHandler: {
                (
                data, response, error) in
                
                guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                    return
                }
                
                
                if let image = UIImage(data: data!) {
                    
                    // salvar no disco
                    DispatchQueue.main.async(execute: {
                        try? data?.write(to: URL(fileURLWithPath: filePath), options: [.atomic]);
                    })
                    
                    
                    DispatchQueue.main.async(execute: {
                        do {
                            imageview.image = image
                        }
                    })
                    
                }
                
            })
            
            task.resume()
            
        }
        
    }
    
}
