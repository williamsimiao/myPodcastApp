//
//  PerfilViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import HSPopupMenu

class PerfilViewController: InheritanceViewController, HSPopupMenuDelegate {
    
    @IBOutlet weak var imgUsuario: UIImageView!
    @IBOutlet weak var lblNome: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnPremium: UIButton!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    var cod_usuario:String!
    var maxVisitas = 3
    var menuArray: [HSMenu] = []
    var isVisitante = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //        let menu1 = HSMenu(icon: nil, title: "Editar")
        //        let menu2 = HSMenu(icon: nil, title: "Configurações")
        //        let menu3 = HSMenu(icon: nil, title: "Sair")
        //
        //        menuArray = [menu1, menu2, menu3]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let prefs:UserDefaults = UserDefaults.standard
        isVisitante = prefs.bool(forKey: "isVisitante") as Bool
        
        if isVisitante {
            setUIforVisitante()
        }
        else {
            setUIForUser()
        }
    }
    
    func setUIforVisitante() {
        lblNome.text = "Visitante"
        lblEmail.isHidden = true
        
        imgUsuario.layer.cornerRadius = 50
        imgUsuario.clipsToBounds = true
        imgUsuario.layer.borderWidth = 2
        imgUsuario.layer.borderColor = UIColor.white.cgColor
        
        self.view.isUserInteractionEnabled = false
        self.view.alpha = 0.5
        let alert = UIAlertController(
            title: "Faça o login",
            message: "Entre com uma conta para personalizar o aplicativo",
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "Entrar", style: UIAlertAction.Style.default, handler:{(ACTION :UIAlertAction) in
            AppService.util.logout()
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler:{(ACTION :UIAlertAction) in
            guard let baseVC = self.storyboard?.instantiateViewController(
                withIdentifier: "BaseViewController")
                as? BaseViewController else {
                    assertionFailure("No view controller ID BaseViewController in storyboard")
                    return
            }
            self.present(baseVC, animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func setUIForUser() {
        let prefs:UserDefaults = UserDefaults.standard
        
        cod_usuario = prefs.string(forKey: "cod_usuario")!
        
        let nome = prefs.string(forKey: "nome")!
        let foto = prefs.string(forKey: "foto")!
        let email = prefs.string(forKey: "email")!
        
        lblNome.text = nome
        lblEmail.text = email
        
        NSLog("foto %@", foto)
        
        
        // image rounded
        imgUsuario.layer.cornerRadius = 50
        imgUsuario.clipsToBounds = true
        imgUsuario.layer.borderWidth = 2
        imgUsuario.layer.borderColor = UIColor.white.cgColor
        
        // carregar foto do usuario
        imgUsuario.image = UIImage(named: "sem_img.png")
        if AppService.util.isNotNull(foto as AnyObject?) {
            AppService.util.load_image_usuario(foto, cod_usuario: cod_usuario, imageview: imgUsuario)
        }
    }
    
    func popMenu1() {
        let popupMenu = HSPopupMenu(menuArray: menuArray, arrowPoint: CGPoint(x: UIScreen.main.bounds.width-35, y: 64))
        popupMenu.popUp()
        popupMenu.delegate = self
    }
    
    func popupMenu(_ popupMenu: HSPopupMenu, didSelectAt index: Int) {
        switch index {
        case 0:
            performSegue(withIdentifier: "goto_editarPerfil", sender: self)
        case 1:
            print("Settings")
        case 2:
            logout()
        default:
            print("None of the above")
        }
    }
    
    func logout() {
        if isVisitante {
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(false, forKey: "isVisitante")
        }
        else {
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            
            loginManager.logOut()
            
            AppService.util.removeUserDataFromUserDefaults()
        }
        AppService.util.logout()
    }
    
    //    @IBAction func clickMenu(_ sender: Any) {
    //
    //        popMenu1()
    //
    //    }
    
    ///////
    
    @IBAction func clickFaleConosco(_ sender: Any) {
        performSegue(withIdentifier: "to_faleConosco", sender: self)
    }
    
    @IBAction func clickEditarPerfil(_ sender: Any) {
        performSegue(withIdentifier: "to_editarPerfil", sender: self)
    }
    
    
    @IBAction func clickSugerir(_ sender: Any) {
        performSegue(withIdentifier: "to_sugerir", sender: self)
    }
    
    @IBAction func clickLogout(_ sender: Any) {
        
        let refreshAlert = UIAlertController(title: "Sair do ResumoCast", message: "Deseja realmente sair?", preferredStyle: .alert)
        
        
        refreshAlert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        
        refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
            
            self.logout()
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
}
