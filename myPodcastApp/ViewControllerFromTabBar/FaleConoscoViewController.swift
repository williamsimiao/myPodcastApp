//
//  FaleConoscoViewController.swift
//  myPodcastApp
//
//  Created by William on 04/04/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class FaleConoscoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var blackBox: UIView!
    @IBOutlet weak var assuntoEdt: LoginTextField!
    @IBOutlet weak var mensagemEdt: LoginTextField!
    @IBOutlet weak var enviarBtn: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var error_msg:String!
    var success:Bool!
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var radius = CGFloat(20)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blackBox.layer.cornerRadius = radius
        
        enviarBtn.layer.cornerRadius = 20
        enviarBtn.clipsToBounds = true
        enviarBtn.layer.borderWidth = 1
        enviarBtn.layer.borderColor = ColorWeel().orangeColor.cgColor
        
        assuntoEdt.delegate = self
        assuntoEdt.tag = 0
        mensagemEdt.delegate = self
        mensagemEdt.tag = 1
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SugerirViewController.returnTextView(gesture:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loading.isHidden = true
        success = false
        error_msg = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(SugerirViewController.keyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SugerirViewController.keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loading.isHidden = true
        print("viewWillDisappear")
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func clickEnviar(_ sender: Any) {
        let prefs:UserDefaults = UserDefaults.standard
        let cod_usuario = prefs.string(forKey: "cod_usuario")
        let assunto = assuntoEdt.text
        let mensagem = mensagemEdt.text
        
        if AppService.util.isValidString(aString: assunto) == false ||
            AppService.util.isValidString(aString: mensagem) == false {
            
            AppService.util.alert("Erro nos dados", message: "Preencha os campos obrigatórios")
            return
        }
        
        let link = AppConfig.urlBaseApi + "contato.php"
        let buscaUrl = URL(string: link)
        let keys = ["cod_usuario", "assunto", "mensagem"]
        let values = [cod_usuario!, assunto!, mensagem!]
        makeResquest(url: buscaUrl!, keys: keys, values: values)
    }
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    ///////
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
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? LoginTextField {
            nextField.becomeFirstResponder()
            activeField = nextField
        } else {
            // Not found, so remove keyboard.
            activeField?.resignFirstResponder()
            activeField = nil
        }
        
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
    ///////

}

extension FaleConoscoViewController {
    
    func makeResquest(url: URL, keys: [String], values: [String]) {
        var request = URLRequest(url: url)
        let session = URLSession.shared
        
        loading.isHidden = false
        loading.startAnimating()
        
        let tuples = zip(keys, values)
        var keyValueArray = [String]()
        for (key, value) in tuples {
            let paramValue = key + "=" + value
            keyValueArray.append(paramValue)
        }
        let joinedData = keyValueArray.joined(separator: "&")
        
        //        let postData:Data = joinedData.data(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!
        //        let postLength:NSString = String( postData.count ) as NSString
        
        let post = joinedData as NSString
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.httpBody = postData
        
        //        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        print("REQUEST: \(request)")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print(error)
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
                
                NSLog("FaleConoscoVC SUCCESS");
            } else {
                
                NSLog("FaleConoscoVC ERROR");
                error_msg = (json.value(forKey: "error") as! String)
                
            }
        }
        catch
        {
            print("error FaleConoscoVC")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
        
    }
    
    func onResultReceived() {
        
        loading.isHidden = true
        loading.stopAnimating()
        dismiss(animated: true, completion: nil)
        
        
        if self.success {
            print("success na FaleConoscoVC")
        }
        else {
            print("Erro noa FaleConoscoVC")
        }
        
    }
}
