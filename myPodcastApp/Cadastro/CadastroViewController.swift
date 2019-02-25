//
//  CadastroViewController.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

import UIKit

class CadastroViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var edtNome: UITextField!
    @IBOutlet weak var edtSobrenome: UITextField!
    @IBOutlet weak var edtEmail: UITextField!
    @IBOutlet weak var edtSenha: UITextField!
    @IBOutlet weak var edtConfirmarSenha: UITextField!
    @IBOutlet weak var btnCadastrar: UIButton!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    
    var success:Bool = false
    var error_msg:String = ""
    let radius = CGFloat(20)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.isHidden = true
        
        edtNome.delegate = self
        edtSobrenome.delegate = self
        edtEmail.delegate = self
        edtSenha.delegate = self
        edtConfirmarSenha.delegate = self
        
        
        btnCadastrar.layer.cornerRadius = radius
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
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
//        let newYPosition = self.scrollView.frame.height - textField.frame.origin.y
//        self.scrollView.contentOffset.y = newYPosition
        
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
        
        if self.keyboardHeight != nil {
            
            UIView.animate(withDuration: 0.3) {
                self.constraintContentHeight.constant -= self.keyboardHeight
                self.scrollView.contentOffset = self.lastOffset
            }
            
        }
        
        self.keyboardHeight = nil
    }
    
    func cadastrar() {
        
        let pnome = edtNome.text! as String
        let psobrenome = edtSobrenome.text! as String
        let pemail = edtEmail.text! as String
        let psenha = edtSenha.text! as String
        
        
        if !AppService.util.isConnectedToNetwork() {
            AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
            return
        }
        
        
        
        // validar nome
        if ( pnome.isEqual("") ) {
            AppService.util.alert("Erro nos dados", message: "Informe o nome!")
            return
        }
        
        // validar sobrenome
        if ( psobrenome.isEqual("") ) {
            AppService.util.alert("Erro nos dados", message: "Informe o sobrenome!")
            return
        }
        
        // validar email
        if ( pemail.isEqual("") ) {
            AppService.util.alert("Erro nos dados", message: "Informe o email!")
            return
        }
        
        // validar senha
        if ( psenha.isEqual("") ) {
            AppService.util.alert("Erro nos dados", message: "Informe a senha!")
            return
        }
        
        let nomeCompleto = pnome + " " + psobrenome
        
        
        loading.isHidden = false
        loading.startAnimating()
        
        btnCadastrar.isEnabled = false
        
        
        let post:NSString = "nome=\(nomeCompleto)&email=\(pemail)&senha=\(psenha)" as NSString
        
        print(post)
        
        /*post = (post as String) + "" +  as NSString
         post = (post as String) + "&email=" + pemail as NSString
         post = (post as String) + "&senha=" + psenha as NSString
         post = (post as String) + "&num_id_ios=" + num_id_ios as NSString*/
        
        
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        
        let postLength:NSString = String( postData.count ) as NSString
        
        let link = AppConfig.urlBaseApi + "cadastrar.php"
        
        print(link)
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
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
            success = json.value(forKey: "success") as! Bool
            
            if (success) {
                NSLog("enviado SUCCESS");
            } else {
                NSLog("enviado ERROR");
                error_msg = json.value(forKey: "error") as! String
            }
        }
        catch {
            print("error")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {
        btnCadastrar.isEnabled = true
        loading.isHidden = true
        loading.stopAnimating()
        montarDados()
    }
    
    func montarDados() {
        
        if (success) {
            
            let refreshAlert = UIAlertController(title: "Cadastrado com sucesso", message: "Seu cadastro foi confirmado! Acesse e faça o login.", preferredStyle: UIAlertController.Style.alert)
        
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.dismiss(animated: true, completion: nil)
//                self.performSegue(withIdentifier: "goto_login", sender: self)

            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        } else {
            AppService.util.alert("Erro no Cadastro", message: error_msg)
        }
        
    }
    
    
    @IBAction func clickCadastrar(_ sender: Any) {
        
        cadastrar()
    
    }
    
    
    @IBAction func clickVoltar(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: Any) {
        let textField = sender as! CadastroTextField

//        self.scrollView.contentOffset.y = self.scrollView.contentSize.height - textField.bounds.origin.y - textField.bounds.size.height
//        self.scrollView.contentOffset.y = textField.bounds.origin.y
    }
}
