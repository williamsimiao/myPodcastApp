//
//  PrimeiraViewController.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class PrimeiraViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var btnEntrar: UIButton!
    @IBOutlet var btnFacebook: FBSDKLoginButton!
    @IBOutlet var loading: UIActivityIndicatorView!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnCriar: UIButton!
    
    var id_facebook:String!
    var name:String!
    var email:String!
    var birthday:String!
    var gender:String!
    var url_foto:String!
    
    
    var usuario:NSDictionary = NSDictionary()
    
    var success:Bool = false
    var error_msg:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    func setupLayout() {
        loading.isHidden = true
        let radius = CGFloat(15)
        btnFacebook.layer.cornerRadius = radius
        btnFacebook.clipsToBounds = true
        
        btnEntrar.layer.cornerRadius = radius
        btnEntrar.clipsToBounds = true
        btnEntrar.layer.borderWidth = 1
        btnEntrar.layer.borderColor = ColorWeel().orangeColor.cgColor

        btnGoogle.layer.cornerRadius = radius
        btnGoogle.clipsToBounds = true
        
//        configureFacebook()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginInProcess() {
        loading.isHidden = false
        loading.startAnimating()
        btnFacebook.isEnabled = false
//        btnGoogle.isEnabled = false
//        btnEntrar.isEnabled = false
//        btnCriar.isEnabled = false
    }
    
    func configureFacebook() {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        btnFacebook.setAttributedTitle(NSAttributedString(string: "Entrar com o Facebook"), for: .normal)
        btnFacebook.readPermissions = ["public_profile", "email"]
        let layoutConstraintsArr = btnFacebook.constraints
        // Iterate over array and test constraints until we find the correct one:
        for lc in layoutConstraintsArr { // or attribute is NSLayoutAttributeHeight etc.
            if ( lc.constant == 28 ){
                // Then disable it...
                lc.isActive = false
                break
            }
        }

        btnFacebook.delegate = self
    }
    
    func loginFacebook() {
        
        var num_id_ios:String = ""
        
        if !AppService.util.isConnectedToNetwork() {
            AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
            return
        }
        
        loginInProcess()
        var dados:String = ""
        dados = dados + "&num_facebook=" + id_facebook
        dados = dados + "&nome=" + name
        dados = dados + "&email=" + email
        dados = dados + "&url_foto=" + url_foto
        dados = dados + "&birthday=" + birthday
        dados = dados + "&gender=" + gender
        dados = dados + "&num_id_ios=" + num_id_ios
        
        let post = dados as String
        let postData:Data = Data(post.utf8)
        let postLength:NSString = String( postData.count ) as NSString
        
        let link = AppConfig.urlBaseApi + "loginFacebook.php"
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
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
            let psuccess:Bool = json.value(forKey: "success") as! Bool
            
            success = psuccess
            
            if (success) {
                
                NSLog("Login SUCCESS");
                
                // dados do json
                usuario = json.object(forKey: "usuario") as! NSDictionary
                
            } else {
                
                NSLog("Login ERROR");
                
                error_msg = json.value(forKey: "error") as! String
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
        btnFacebook.isEnabled = true
        loading.isHidden = true
        loading.stopAnimating()
        
        if self.success {
            AppService.util.putuserDataOnUserDefaults(usuario: self.usuario)
            self.performSegue(withIdentifier: "goto_main", sender: self)
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg as String)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            AppService.util.alert("Erro no Login Facebook", message: "Não foi possível fazer login")
            
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                getDadosFacebook()
                
            } else {
                
                AppService.util.alert("Erro no Login", message: "Não foi possível fazer login")
                
            }
            
        }
        
    }
    
    func getDadosFacebook() {
        
        if (FBSDKAccessToken.current() != nil) {
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, gender, birthday, picture.type(large)"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                let data:[String:AnyObject] = result as! [String : AnyObject]
                
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(String(describing: error))")
                    
                    AppService.util.alert("Erro no Login", message: (error as! String?)!)
                    
                }
                else
                {
                    print("fetched user: \(String(describing: result))")
                    
                    self.id_facebook = data["id"] as! String
                    self.name = data["name"] as! String
                    self.email = data["email"] as! String
                    self.gender = "" //data["gender"] as! String
                    self.birthday = ""
                    
                    let picture = data["picture"] as! [String:AnyObject]
                    let pictureData = picture["data"] as! [String:AnyObject]
                    
                    self.url_foto = pictureData["url"] as! String
                    
                    self.loginFacebook()
                }
                
            })
            
        }
        
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        loginManager.logOut()
        
        
    }
    
    @IBAction func clickFacebook(_ sender: Any) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if (error != nil) {
                print("Process error")
            } else if (result?.isCancelled)! {
                print("Canceled")
            } else {
                print("Loged in")
            }
        }
    }
    
    @IBAction func clickEntrar(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goto_login", sender: self)
        
    }
    
    @IBAction func clickCriar(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goto_cadastro", sender: self)
        
    }
    
}
