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
    
    var menuArray: [HSMenu] = []
    var isVisitante = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs:UserDefaults = UserDefaults.standard
        isVisitante = prefs.bool(forKey: "isVisitante") as Bool

        if isVisitante {
            setUIforVisitante()
        }
        else {
            setUIForUser()
        }
        
        let menu1 = HSMenu(icon: nil, title: "Editar")
        let menu2 = HSMenu(icon: nil, title: "Configurações")
        let menu3 = HSMenu(icon: nil, title: "Sair")
        
        menuArray = [menu1, menu2, menu3]
    }
    
    func setUIforVisitante() {
        lblNome.text = "Visitante"
        lblEmail.isHidden = true
        
        imgUsuario.layer.cornerRadius = 50
        imgUsuario.clipsToBounds = true

    }
    
    func setUIForUser() {
        let prefs:UserDefaults = UserDefaults.standard
        
        cod_usuario = prefs.string(forKey: "cod_usuario")!
        
        let nome = prefs.string(forKey: "nome")!
        let foto = prefs.string(forKey: "foto")!
        let email = prefs.string(forKey: "email")!
        
        lblNome.text = nome
        lblEmail.text = email
        
        
        // image rounded
        imgUsuario.layer.cornerRadius = 50
        imgUsuario.clipsToBounds = true
        
        // carregar foto do usuario
        //imgUsuario.image = UIImage(named: "sem_img.png")
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
    
    @IBAction func clickConfig(_ sender: Any) {
        
    }
    @IBAction func clickEditarPerfil(_ sender: Any) {
        performSegue(withIdentifier: "to_editarPerfil", sender: self)
    }
    
    @IBAction func clickPag(_ sender: Any) {
    }
    
    @IBAction func clickSugerir(_ sender: Any) {
        performSegue(withIdentifier: "to_sugerir", sender: self)
    }
    @IBAction func clickLogout(_ sender: Any) {
        logout()
    }
    
}
