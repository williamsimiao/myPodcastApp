//
//  EditarPerfilViewController.swift
//  myPodcastApp
//
//  Created by William on 18/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MobileCoreServices

class EditarPerfilViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var imgUsuario: UIImageView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var edtNome: CadastroTextField!
    @IBOutlet weak var edtFone: CadastroTextField!
    @IBOutlet weak var edtDataNascimento: CadastroTextField!
    @IBOutlet weak var edtSexo: CadastroTextField!
    @IBOutlet weak var edtEmail: CadastroTextField!
    
    @IBOutlet weak var btnSalvar: UIBarButtonItem!
    
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var datePicker : UIDatePicker?
    var sexoPicker : UIPickerView!
    var escolaridadePicker : UIPickerView!
    
    var fieldsArray = [String]()
    var keysArray = [String]()
    
    var cod_usuario:String = ""
    var url_foto_nova:String = ""
    var nome_foto:String = ""
    
    var success:Bool = false
    var error_msg:String = ""
    let radius = CGFloat(20)
    var empreendeButtonHasMark = true
    let sexoArray = ["Feminino", "Masculino"]
    let escolaridadeAray = ["Ensino Fundamental", "Ensino Médio", "Ensino Superior", "Pós-Graduação", "Mestrado", "Doutorado"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imgUsuario.layer.cornerRadius = 50
        imgUsuario.clipsToBounds = true
        imgUsuario.layer.borderWidth = 2
        imgUsuario.layer.borderColor = UIColor.white.cgColor
        
        cameraBtn.layer.cornerRadius = cameraBtn.frame.height/2
        cameraBtn.clipsToBounds = true
        
        
        loading.isHidden = true
        
        
        edtDataNascimento.delegate = self
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(EditarPerfilViewController.dateChanged(datePicker:)), for: .valueChanged )
        edtDataNascimento.inputView = datePicker
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(CadastroViewController.viewTapped(gestureReconizer:)))
        view.addGestureRecognizer(tapGestureReconizer)
        
        edtSexo.delegate = self
        sexoPicker = UIPickerView()
        sexoPicker.dataSource = self
        sexoPicker.delegate = self
        edtSexo.inputView = sexoPicker
        
        edtFone.delegate = self
        
        /*edtEscolaridade.delegate = self
         escolaridadePicker = UIPickerView()
         escolaridadePicker.dataSource = self
         escolaridadePicker.delegate = self
         edtEscolaridade.inputView = escolaridadePicker*/
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        populateFields()
        
        
        addButtonDone()
        registerForKeyboardNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        keysArray.removeAll()
        fieldsArray.removeAll()
    }
    
    func populateFields() {
        let prefs:UserDefaults = UserDefaults.standard
        
        cod_usuario = prefs.string(forKey: "cod_usuario")!
        
        let fullName = prefs.string(forKey: "nome")
        
        //let items = fullName!.components(separatedBy: " ")
        edtNome.text = fullName //items[0]
        //edtSobrenome.text = items[1]
        edtEmail.text = prefs.string(forKey: "email")
        edtSexo.text = prefs.string(forKey: "sexo")
        edtFone.text = prefs.string(forKey: "celular")
        edtDataNascimento.text = prefs.string(forKey: "dat_nascimento")
        
        let foto = prefs.string(forKey: "foto")!
        
        if AppService.util.isNotNull(foto as AnyObject?) {
            AppService.util.load_image_usuario(foto, cod_usuario: cod_usuario, imageview: imgUsuario)
        }
        
    }
    
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        
        /*//Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = self.view.frame
        
        aRect.size.height -= keyboardSize!.height
        
        if let activeField = self.activeField {
            
            if (!aRect.contains(activeField.frame.origin)){
                
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
                
            }
        }*/
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        
        /*//Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0) // UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        self.view.endEditing(true)*/
        
    }
    
    func addButtonDone() {
        
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(self.clickDone(_:)))
        
        toolbarDone.items = [barBtnDone] // You can even add cancel button too
        
        edtFone.inputAccessoryView = toolbarDone
        //edtDatNascimento.inputAccessoryView = toolbarDone
    }
    
    @objc func clickDone(_ btn: UIBarButtonItem) {
        activeField?.resignFirstResponder()
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func createRequest () -> URLRequest {
        
        let nom_usuario = edtNome.text!
        let celular = edtFone.text!
        let dat_nascimento = edtDataNascimento.text!
        let sexto = edtSexo.text!
        let email = edtEmail.text!
        
        let param = [
            "cod_usuario"  : cod_usuario,
            "nom_usuario"  : nom_usuario,
            "dsc_email" : email,
            "num_celular" : celular,
            "dsc_sexo" : sexto,
            "dat_nascimento" : dat_nascimento
        ]
        
        
        NSLog("param %@", param)
        
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: AppConfig.urlBaseApi + "salvarDados.php")!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        request.httpBody = createBodyWithParameters(param, filePathKey: "image", paths: [url_foto_nova], boundary: boundary)
        
        return request as URLRequest
    }
    
    func createBodyWithParameters(_ parameters: [String: String]?, filePathKey: String?, paths: [String]?, boundary: String) -> Data {
        
        let body = NSMutableData()
        
        if parameters != nil {
            
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        if paths != nil {
            
            for path in paths! {
                
                if !path.isEmpty {
                    
                    let url = URL(fileURLWithPath: path)
                    let filename = url.lastPathComponent
                    
                    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
                    
                    let mimetype = mimeTypeForPath(path)
                    
                    body.append(Data("--\(boundary)\r\n".utf8))
                    body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
                    body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
                    body.append(data)
                    body.append(Data("\r\n".utf8))
                }
                
            }
            
        }
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body as Data
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func mimeTypeForPath(_ path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
            
        }
        
        return "application/octet-stream";
    }
    
    func salvar() {
        
        loading.isHidden = false
        loading.startAnimating()
        
        btnSalvar.isEnabled = false
        
        
        let request = createRequest()
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            NSLog("response %@", dataString!)
            
            self.extract_json_data(dataString!)
            
        })
        
        task.resume()
        
    }
    
    func extract_json_data(_ data:NSString) {
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            success = json.value(forKey: "success") as! Bool
            
            if (success) {
                NSLog("salvo SUCCESS")
                
                nome_foto = json.value(forKey: "foto") as! String
                
            } else {
                
                NSLog("salvo ERROR");
                
                let perror_msg:String = json.value(forKey: "error") as! String
                
                error_msg = perror_msg
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
        
        btnSalvar.isEnabled = true
        
        loading.isHidden = true
        loading.stopAnimating()
        
        if (success) {
            
            AppService.util.changeUserField(key: "nome", value: edtNome.text!)
            AppService.util.changeUserField(key: "email", value: edtEmail.text!)
            AppService.util.changeUserField(key: "sexo", value: edtSexo.text!)
            AppService.util.changeUserField(key: "celular", value: edtFone.text!)
            AppService.util.changeUserField(key: "dat_nascimento", value: edtDataNascimento.text!)
            AppService.util.changeUserField(key: "foto", value: nome_foto)
            
            
            
            /*AppService.user.nome = nom_usuario
             AppService.user.foto = url_foto
             
             AppService.user.save()*/
            
            
            // salvar dados do usuario na session
            /*let prefs:UserDefaults = UserDefaults.standard
             
             prefs.set(nom_usuario, forKey: "nom_usuario")
             prefs.set(url_foto, forKey: "url_foto")
             
             //prefs.set(dat_nascimento, forKey: "dat_nascimento")
             //prefs.set(cidade, forKey: "cidade")
             
             prefs.synchronize()*/
            
            navigationController!.popViewController(animated: true)
            
        } else {
            AppService.util.alert("Erro ao Salvar", message: error_msg)
        }
        
    }
    
    func setFoto(_ image: UIImage) {
        
        print("setFoto")
        
        //imgUsuario.image = sFunc_imageFixOrientation(image)
        
        var size:CGSize!
        
        if (image.size.width > image.size.height) {
            size = CGSize(width: 800, height: 600)
        } else {
            size = CGSize(width: 600, height: 800)
        }
        
        let imageNova = self.resizeImage(image: image, targetSize: size)
        
        imgUsuario.image = imageNova
        
        self.dismiss(animated: true, completion: nil);
        
        
        // salvar imagem
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        
        let time = Date().timeIntervalSince1970 * 1000
        
        nome_foto = "temp_usuario_" + String(time) + ".jpg"
        
        NSLog("nome_foto %@", nome_foto)
        
        let filePath = documentsPath + "/" + nome_foto;
        
        
        
        let imageData = imageNova.jpegData(compressionQuality: 1.0)
        
        try? imageData!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
        
        
        url_foto_nova = filePath
        
        NSLog("url_foto_nova %@", url_foto_nova)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickCamera(_ sender: Any) {
        
        NSLog("clickMudarFoto")
        
        CameraHandler.shared.showActionSheet(vc: self)
        
        CameraHandler.shared.imagePickedBlock = { (image) in
            
            NSLog("imagePickedBlock")
            
            self.setFoto(image)
            
        }
        
    }
    
    @IBAction func clickSalvar(_ sender: Any) {
        
        guard AppService.util.isConnectedToNetwork() else {
            AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
            return
        }
        
        salvar()
        
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        edtDataNascimento.text = dateFormatter.string(from: datePicker.date)
        //        view.endEditing(true )
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    @objc func viewTapped(gestureReconizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}




//MARK - pickerView dataSource and Delegate
extension EditarPerfilViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sexoPicker {
            return sexoArray.count
        }
        else if pickerView == escolaridadePicker {
            return escolaridadeAray.count
        }
        else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == sexoPicker {
            return sexoArray[row]
        }
        else if pickerView == escolaridadePicker {
            return escolaridadeAray[row]
        }
        else {
            return escolaridadeAray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sexoPicker {
            edtSexo.text = sexoArray[row]
        }
        /*else if pickerView == escolaridadePicker {
         edtEscolaridade.text = escolaridadeAray[row]
         }
         else {
         edtEscolaridade.text = escolaridadeAray[row]
         }*/
        
        self.view.endEditing(true)
        //        btnDone.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        /*if textField == edtDataNascimento {
         
         return edtDataNascimento.shouldChangeCharacters(in: range, replacementString: string)
         
         }*/
        
        return true
    }
    
}
