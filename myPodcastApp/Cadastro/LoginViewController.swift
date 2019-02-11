//
//  LoginViewController.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtSenha: UITextField!
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    var usuario:NSDictionary = NSDictionary()
    
    var success:Bool = false
    var error_msg:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.isHidden = true
        
        btnLogin.layer.cornerRadius = 10
        btnLogin.clipsToBounds = true
        
        txtEmail.delegate = self
        txtSenha.delegate = self
        
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.returnTextView(gesture:))))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if keyboardHeight == nil {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            
            self.scrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil
    }
    
    func login() {
        
        let num_id_ios:String = ""
        /*if let token = FIRInstanceID.instanceID().token() {
         
         num_id_ios = token
         
         }*/
        
        
        let pemail = txtEmail.text! as String
        let psenha = txtSenha.text! as String
        
        
        if !AppService.util.isConnectedToNetwork() {
            AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
            return
        }
        
        
        
        // validar email e senha
        if ( pemail.isEqual("") || psenha.isEqual("") ) {
            AppService.util.alert("Erro no Login", message: "Informe o email e senha!")
            return
        }
        
        
        loading.isHidden = false
        loading.startAnimating()
        
        btnLogin.isEnabled = false
        
        
        //let post:NSString = "cod_evento=\(AppConfig.cod_evento)&email=\(pemail)&senha=\(psenha)" as NSString
        
        //print(post)
        
        var dados:String = ""
        dados = dados + "email=" + pemail
        dados = dados + "&senha=" + psenha
        dados = dados + "&num_id_ios=" + num_id_ios
        
        
        
        let post = dados as NSString
        
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        
        let postLength:NSString = String( postData.count ) as NSString
        
        
        
        let link = AppConfig.urlBaseApi + "login.php"
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
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
        
        DispatchQueue.main.async(execute: montarDados)
    }
    
    func montarDados() {
        
        btnLogin.isEnabled = true
        
        loading.isHidden = true
        loading.stopAnimating()
        
        
        if (success) {
            
            let cod_usuario = usuario.value(forKey: "id") as! String
            let nome = usuario.value(forKey: "nome") as! String
            let foto = usuario.value(forKey: "foto") as! String
            let email = usuario.value(forKey: "email") as! String
            let celular = usuario.value(forKey: "celular") as! String
            let sexo = usuario.value(forKey: "sexo") as! String
            let dat_nascimento = usuario.value(forKey: "dat_nascimento") as! String
            let cidade = usuario.value(forKey: "cidade") as! String
            
            
            
            // salvar dados do usuario na session
            let prefs:UserDefaults = UserDefaults.standard
            
            prefs.set(cod_usuario, forKey: "cod_usuario")
            prefs.set(nome, forKey: "nome")
            prefs.set(foto, forKey: "foto")
            prefs.set(email, forKey: "email")
            prefs.set(celular, forKey: "celular")
            prefs.set(sexo, forKey: "sexo")
            prefs.set(dat_nascimento, forKey: "dat_nascimento")
            prefs.set(cidade, forKey: "cidade")
            
            prefs.set(1, forKey: "isLogado")
            
            prefs.synchronize()
            
            
            // fechar login
            //self.dismiss(animated: true, completion: nil)
            
            self.performSegue(withIdentifier: "goto_main", sender: self)
            
        } else {
            
            AppService.util.alert("Erro no Login", message: error_msg as String)
            
        }
        
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        
        login()
        
    }
    
    
    @IBAction func clickEsqueceuSenha(_ sender: Any) {
        
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "goto_esqueceu_senha", sender: nil)
        })
        
    }
    
    @IBAction func clickCadastro(_ sender: Any) {
        
        DispatchQueue.main.async(execute: {
            self.performSegue(withIdentifier: "from_login_to_cadatro", sender: nil)
        })
        
    }
    
    @IBAction func clickVoltar(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

