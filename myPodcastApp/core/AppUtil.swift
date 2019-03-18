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
    let maxVisitas = 3
    var realm = AppService.realm()

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
    
    func load_image_autor(_ link:String, cod_autor:String, imageview:UIImageView) {
        
        // verificar se image jah existe
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let filePath = documentsPath + "/autor_" + cod_autor + "_200";
        
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
    
    func downloadAudio(urlString: String, cod_resumo: String) {
        print(urlString)
        if let audioUrl = URL(string: urlString) {
            
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
                        
                        DispatchQueue.main.async(execute: {
                            self.markResumoAsDownloaded(cod_resumo: cod_resumo)
                        })

                        
                    } catch let error as NSError {
                        print("Erro no Download")
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func markResumoAsDownloaded(cod_resumo: String) {
        let resumos = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo)
        guard let resumoEntity = resumos.first else {
            //            Toast(text: "Não foi possivel fazer o download", duration: 1).show()
            //            Delay.short
            print("Não foi possivel fazer o download")
            return
        }
        
        try! self.realm.write {
            resumoEntity.downloaded = 1
            self.realm.add(resumoEntity, update: true)
            NSLog("downloaded resumo %@", resumoEntity.cod_resumo)
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
    
    func checkIfVisitanteIsAbleToPlay(resumo: Resumo) -> Bool{
        let prefs:UserDefaults = UserDefaults.standard
        let isVisitante = prefs.bool(forKey: "isVisitante") as Bool

        if isVisitante {
            let episodeWasPlayed = resumo.progressPodcast_10 > 0.0 && resumo.progressPodcast_40_f > 0.0 && resumo.progressPodcast_40_p > 0.0
            if episodeWasPlayed {
                return true
            }
            else if VisitasLimitReached() {
                return false
            }
        }
        return true
    }
    
    func VisitasLimitReached() -> Bool {
        var resumosIniciados = [Resumo]()
        
        let startedResumo10 = realm.objects(ResumoEntity.self).filter("progressResumo10 > 0.0")
        let startedPodcast_10 = realm.objects(ResumoEntity.self).filter("progressPodcast_40_f > 0.0")
        
        //TODO: exchange the code bellow for caling resultsToResumosArray
        for resumoEntity in startedResumo10 {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumosIniciados.append(resumo)
        }
        for resumoEntity in startedPodcast_10 {
            let resumo = Resumo(resumoEntity: resumoEntity)
            resumosIniciados.append(resumo)
        }

        if resumosIniciados.count >= maxVisitas {
            return true
        }
        return false
    }
    
    func handleNotAllowed() {
        let alert = UIAlertController(
            title: "Faça o login",
            message: "Você já consumiu o limite de conteúdo para visitantes. Realize o login para continuar usando o aplicativo",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertAction.Style.default, handler:{(ACTION :UIAlertAction) in
            AppService.util.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler:{(ACTION :UIAlertAction) in
        }))
        self.currentView().present(alert, animated: true, completion: nil)
    }
    
    func logout() {
        playerManager.shared.stopPlayer()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PrimeiraVC")
        self.currentView().present(vc, animated: true, completion: nil)
    }
    
    func createURLWithComponents(path: String, parameters: [String], values: [String]) -> URL? {
        
        var url = AppConfig.urlBaseApi
        url += path + "?"
        // add params
        var paramValueArray = [String]()
        let tuples = zip(parameters, values)
        for (parameter, value) in tuples {
            let paramValue = parameter + "=" + value
            paramValueArray.append(paramValue)
        }
        url += paramValueArray.joined(separator: "&")
        
        return URL(string: url)
    }
    
    func convertDictArrayToResumoArray(dictResumoArray:[[String:AnyObject]]) -> [Resumo] {
        var myResumos = [Resumo]()
        for resumoDict in dictResumoArray {
            var resumoEntity = ResumoEntity()

            let cod_resumo = resumoDict["cod_resumo"] as! String
            
            let resumoInit = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
            
            if resumoInit?.cod_resumo == cod_resumo {
                resumoEntity = resumoInit!
                print("Resumo exists on Realm, Updating anyway")
            }
            
            //Updating
            do {
                try resumoEntity.update(episodeDictonary: resumoDict)
            }
            catch AppError.dictionaryIncomplete {
                print("dictionaryIncomplete")
            } catch {
                print(error)
            }
            
            //Building Model
            let newResumo = Resumo(resumoEntity: resumoEntity)
            myResumos.append(newResumo)
        }
        return myResumos
    }
    
    func convertDictArrayToAutorArray(dictResumoArray:[[String:AnyObject]]) -> [Autor] {
        var myAutores = [Autor]()
        for autorDict in dictResumoArray {
            var autorEntity = AutorEntity()
            
            let cod_autor = autorDict["cod_autor"] as! String
            
            let autorInit = realm.objects(AutorEntity.self).filter("cod_autor = %@", cod_autor).first
            
            if autorInit != nil {
                //                print("Autor exists on Realm")
            }
            
            autorEntity = AutorEntity(autorDictonary: autorDict)!
            
            try! realm.write {
                self.realm.add(autorEntity, update: true)
            }
            //Building Model
            let newAutor = Autor(autorEntity: autorEntity)
            myAutores.append(newAutor)
        }
        return myAutores
    }
    
}
