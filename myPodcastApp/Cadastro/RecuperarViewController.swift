//
//  RecuperarViewController.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Toast_Swift

class RecuperarViewController: UIViewController {

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var btnRecuperar: UIButton!
    @IBOutlet weak var blackBox: UIView!
    @IBOutlet weak var edtEmail: CadastroTextField!
    var radius = CGFloat(20)
    var success: Bool!
    var error_msg:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        loading.isHidden = true
        blackBox.layer.cornerRadius = radius
        btnRecuperar.layer.cornerRadius = 20
        btnRecuperar.clipsToBounds = true
        btnRecuperar.layer.borderWidth = 1
        btnRecuperar.layer.borderColor = ColorWeel().orangeColor.cgColor
    }
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func clickRecuperar(_ sender: Any) {
        let usuarioEmail = edtEmail.text
        let esqueceuSenhaURL = AppService.util.createURLWithComponents(path: "esqueceuSenha.php", parameters: ["email"], values: [usuarioEmail!])
        print(esqueceuSenhaURL)
        makeResquest(url: esqueceuSenhaURL!)
    }
    
    func makeResquest(url: URL) {
        loading.isHidden = false
        loading.startAnimating()
        
        var request = URLRequest(url: url)
        let session = URLSession.shared

        
        request.timeoutInterval = 10
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            self.extract_json_data(dataString!)
            
        })
        
        task.resume()
    }
    
    func extract_json_data(_ data:NSString) {
        
        NSLog("json %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            self.success = (json.value(forKey: "success") as! Bool)
            if (self.success!) {
                
                NSLog("Recuperar SUCCESS");
                
                
            } else {
                
                NSLog("Recuperar ERROR");
                error_msg = (json.value(forKey: "error") as! String)
            }
        }
        catch
        {
            print("error")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {
        
        loading.isHidden = true
        loading.stopAnimating()
        
        if self.success {
            print("Verifique seu email")
            self.view.makeToast("Verifique seu email", duration: 2.0) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            AppService.util.alert("Erro ao recuperar senha", message: error_msg!)
        }
        
    }
    
    
}
