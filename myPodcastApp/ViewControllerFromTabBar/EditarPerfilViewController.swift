//
//  EditarPerfilViewController.swift
//  myPodcastApp
//
//  Created by William on 18/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class EditarPerfilViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var edtNome: CadastroTextField!
    @IBOutlet weak var edtSobrenome: CadastroTextField!
    @IBOutlet weak var edtFone: CadastroTextField!
    @IBOutlet weak var edtDataNascimento: CadastroTextField!
    
    @IBOutlet weak var edtSexo: CadastroTextField!
    
    @IBOutlet weak var edtEscolaridade: CadastroTextField!
    @IBOutlet weak var edtEmail: CadastroTextField!
//    @IBOutlet weak var btnEmpreende: UIButton!
    @IBOutlet weak var btnAtualizar: UIButton!
    
    var activeField: UITextField?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    var datePicker : UIDatePicker?
    var sexoPicker : UIPickerView!
    var escolaridadePicker : UIPickerView!
    
    var fieldsArray = [String]()
    var keysArray = [String]()
    
    
    var success:Bool = false
    var error_msg:String = ""
    let radius = CGFloat(20)
    var empreendeButtonHasMark = true
    let sexoArray = ["Feminino", "Masculino"]
    let escolaridadeAray = ["Ensino Fundamental", "Ensino Médio", "Ensino Superior", "Pós-Graduação", "Mestrado", "Doutorado"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraBtn.layer.cornerRadius = cameraBtn.frame.height/2
        cameraBtn.clipsToBounds = true
        profilePicBtn.layer.cornerRadius = profilePicBtn.frame.height/2
        profilePicBtn.clipsToBounds = true
        
        loading.isHidden = true
//        btnDone.isHidden = true
        
        edtNome.delegate = self
        edtSobrenome.delegate = self
        
        edtFone.delegate = self
        
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
        
        edtEscolaridade.delegate = self
        escolaridadePicker = UIPickerView()
        escolaridadePicker.dataSource = self
        escolaridadePicker.delegate = self
        edtEscolaridade.inputView = escolaridadePicker
        
        edtEmail.delegate = self
        
        btnAtualizar.layer.cornerRadius = radius
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        populateFields()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        keysArray.removeAll()
        fieldsArray.removeAll()
    }
    
    func populateFields() {
        let prefs:UserDefaults = UserDefaults.standard
        let fullName = prefs.string(forKey: "nome")
        let items = fullName!.components(separatedBy: " ")
        edtNome.text = items[0]
        edtSobrenome.text = items[1]
        edtEmail.text = prefs.string(forKey: "email")
        edtSexo.text = prefs.string(forKey: "sexo")
        edtFone.text = prefs.string(forKey: "celular")
        edtDataNascimento.text = prefs.string(forKey: "dat_nascimento")
        
        let cod_usuario = prefs.string(forKey: "cod_usuario")

        let foto = prefs.string(forKey: "foto")!
        guard let pic = AppService.util.get_image_usuario(foto, cod_usuario: cod_usuario!) else {
            return
        }
        profilePicBtn.setImage(pic, for: .normal)
  
    }
    
    func setUpUI() {
        profilePicBtn.layer.cornerRadius = profilePicBtn.frame.size.height/2
        cameraBtn.layer.cornerRadius = cameraBtn.frame.size.height

    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickProfilePic(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = true
        imgPicker.delegate = self
        imgPicker.allowsEditing = true

        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            AppService.util.alert("Biblioteca de Fotos indisponível", message: "Não foi possivel acessar a Biblioteca de Fotos")
            return
        }

        present(imgPicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        profilePicBtn.setImage(image, for: .normal)
        
    }
    
    @IBAction func clickCamera(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .camera
        imgPicker.allowsEditing = true
        imgPicker.delegate = self
        imgPicker.allowsEditing = true

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            AppService.util.alert("Camera indisponível", message: "Não foi possivel acessar a camera do dispositivo")
            return
        }
        present(imgPicker, animated: true)
    }
    
    @IBAction func clickAtualizar(_ sender: Any) {
        
        guard AppService.util.isConnectedToNetwork() else {
            AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
            return
        }
      
        validateFields()
        
        let nome = edtNome.text! + " " + edtSobrenome.text!
        AppService.util.changeUserField(key: "nome", value: nome)
        AppService.util.changeUserField(key: "email", value: edtEmail.text!)
        AppService.util.changeUserField(key: "sexo", value: edtSexo.text!)
        AppService.util.changeUserField(key: "celular", value: edtFone.text!)
        AppService.util.changeUserField(key: "dat_nascimento", value: edtDataNascimento.text!)
        
        let fotoString = profilePicBtn.imageView?.image!.toBase64()
        AppService.util.changeUserField(key: "image", value: fotoString!)

        let link = AppConfig.urlBaseApi + "salvarDados.php"
        let url = URL(string: link)
        
        let prefs:UserDefaults = UserDefaults.standard
        let cod_usuario = prefs.string(forKey: "cod_usuario")
        
        AppService.util.writeUserImg(image: (profilePicBtn.imageView?.image)!, cod_usuario: cod_usuario!)

        makeResquest(url: url!, keys: keysArray, values: fieldsArray)
    }
    
//    @IBAction func clickBtnEmpreende(_ sender: Any) {
//        if self.empreendeButtonHasMark {
//            self.btnEmpreende.setImage(UIImage(named:
//                "downloadBlack"), for: UIControl.State.normal)
//
//            self.empreendeButtonHasMark = false
//
//        }
//        else {
//            self.btnEmpreende.setImage(UIImage(named:
//                "checkWhite"), for: UIControl.State.normal)
//            self.empreendeButtonHasMark = true
//        }
//    }
    
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

extension EditarPerfilViewController {
    func validateFields() {
        let pnome = edtNome.text! as String
        let psobrenome = edtSobrenome.text! as String
        let pemail = edtEmail.text! as String
        let pnascimento = edtDataNascimento.text! as String
        let pfone = edtFone.text! as String
        let psexo = edtSexo.text! as String
        let pescolaridade = edtEscolaridade.text! as String
        
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
        keysArray.append("cod_usuario")
        keysArray.append("nom_usuario")
        keysArray.append("dsc_email")

        let nomeCompleto = pnome + " " + psobrenome
        fieldsArray.append(nomeCompleto)
        fieldsArray.append(pemail)
        
        
        // checa se existe fone
        if ( pfone != "" ) {
            keysArray.append("num_celular")
            fieldsArray.append(pfone)
        }
        
        
        // checa se existe sexo
        if ( pnascimento != "" ) {
            keysArray.append("dsc_sexo")
            fieldsArray.append(psexo)
        }
        
        // checa se existe nascimento
        if ( pnascimento != "" ) {
            keysArray.append("dat_nascimento")
            fieldsArray.append(pnascimento)
        }
        
//        // checa se existe escolaridade
//        if ( pnascimento != "" ) {
//            keysArray.append("image")
//            fieldsArray.append(pescolaridade)
//        }
        
        keysArray.append("image")

        if profilePicBtn.imageView?.image != nil {
//            fieldsArray.append()
        }
        
        
    }
    
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
            if (self.success) {
                
                NSLog("EditarPerfil SUCCESS");
            } else {
                
                NSLog("EditarPerfil ERROR");
                error_msg = (json.value(forKey: "error") as! String)
                AppService.util.alert("Erro no EditarPerfil", message: error_msg)
                
            }
        }
        catch
        {
            print("error EditarPerfil")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
        
    }
    
    func onResultReceived() {
        
        loading.isHidden = true
        loading.stopAnimating()
        
        
        if self.success {
            self.view.makeToast("Perfil Atualizado", duration: 2.0) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            AppService.util.alert("Erro", message: "Não foi possivel enviar os dados")
        }
        
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
        else if pickerView == escolaridadePicker {
            edtEscolaridade.text = escolaridadeAray[row]
        }
        else {
            edtEscolaridade.text = escolaridadeAray[row]
        }
        self.view.endEditing(true)
//        btnDone.isHidden = true
    }
}
