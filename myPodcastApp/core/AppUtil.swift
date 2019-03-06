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
    
    func load_image_usuario(_ link:String, cod_usuario:String, imageview:UIImageView) {
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/usuario_200_" + cod_usuario;
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            
            do {
                
                imageview.image = UIImage(contentsOfFile: filePath)
                
            }
            
        } else {
            
            let url_foto:String = link
            
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
    
    func load_image_resumo(_ link:String, cod_resumo:String, imageview:UIImageView) {
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/resumo_" + cod_resumo + "_70";
        
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
    
    func get_image_resumo(cod_resumo:String) -> UIImage {
        
        var image:UIImage!
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/resumo_" + cod_resumo + "_70";
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) {
            
            do {
                
                image = UIImage(contentsOfFile: filePath)
                
            }
            
        } else {
            
            image = UIImage(named: "cover_placeholder")!
            
        }
        
        return image
    }
    
    func removeUserDataFromUserDefaults() {
        let prefs:UserDefaults = UserDefaults.standard
        prefs.removeObject(forKey: "cod_usuario")
        prefs.removeObject(forKey: "nome")
        prefs.removeObject(forKey: "foto")
        prefs.removeObject(forKey: "email")
        prefs.removeObject(forKey: "sexo")
        prefs.removeObject(forKey: "celular")
        prefs.removeObject(forKey: "dat_nascimento")
        prefs.removeObject(forKey: "validado_celular")
        prefs.removeObject(forKey: "dat_nascimento")
        prefs.set(0, forKey: "isLogado")

        prefs.synchronize()
    }
    
    func putuserDataOnUserDefaults(usuario:NSDictionary) {
        let cod_usuario = usuario.value(forKey: "cod_usuario") as! String
        let nome = usuario.value(forKey: "nome") as! String
        let foto = usuario.value(forKey: "foto") as! String
        let email = usuario.value(forKey: "email") as! String
        let celular_real : String
        if let celular = usuario.value(forKey: "celular") as? String {
            celular_real = celular
        } else {
            celular_real = ""
        }
        
        let sexo = usuario.value(forKey: "sexo") as! String
        let dat_nascimento = usuario.value(forKey: "dat_nascimento") as! String
        let validado_celular = usuario.value(forKey: "validado_celular") as! String
        
        // salvar dados do usuario na session
        let prefs:UserDefaults = UserDefaults.standard
        
        prefs.set(cod_usuario, forKey: "cod_usuario")
        prefs.set(nome, forKey: "nome")
        prefs.set(foto, forKey: "foto")
        prefs.set(email, forKey: "email")
        prefs.set(sexo, forKey: "sexo")
        prefs.set(celular_real, forKey: "celular")
        prefs.set(dat_nascimento, forKey: "dat_nascimento")
        prefs.set(validado_celular, forKey: "validado_celular")
        
        prefs.set(1, forKey: "isLogado")
        prefs.synchronize()
    }
    
    func populateString(_ text: AnyObject?) -> String {
        if let text = text as? String {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
    
    func dowanloadAudio(urlSring: String) {
        print(urlSring)
        if let audioUrl = URL(string: urlSring) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            // to check if it exists before downloading it
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                
                // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: destinationUrl)
                        print("File moved to documents folder")
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func getPathFromDownloadedAudio(urlString: String) throws -> URL {
        guard let fileURL = URL(string: urlString)  else {
            throw AppError.filePathError
        }
        
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
        
//        guard (destinationUrl != nil) else {
//            throw AppError.filePathError
//        }
        
        return destinationUrl
    }
    
}
