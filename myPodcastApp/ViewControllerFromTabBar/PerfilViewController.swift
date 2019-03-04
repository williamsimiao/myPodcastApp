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
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var btnPremium: UIButton!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    var cod_usuario:String!
    
    var menuArray: [HSMenu] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let prefs:UserDefaults = UserDefaults.standard
        
        cod_usuario = prefs.string(forKey: "cod_usuario")!
        
        let nome = prefs.string(forKey: "nome")!
        let foto = prefs.string(forKey: "foto")!
        let email = prefs.string(forKey: "email")!
        let sexo = prefs.string(forKey: "sexo")!
        
        lblNome.text = nome
        lblEmail.text = email
        lblData.text = "Usuário desde: Mar 2019"
        
        
        // image rounded
        imgUsuario.layer.cornerRadius = 50
        imgUsuario.clipsToBounds = true
        
        
        print(foto)
        
        // carregar foto do usuario
        //imgUsuario.image = UIImage(named: "sem_img.png")
        if AppService.util.isNotNull(foto as AnyObject?) {
            AppService.util.load_image_usuario(foto, cod_usuario: cod_usuario, imageview: imgUsuario)
        }
        
        
        let menu1 = HSMenu(icon: nil, title: "Editar")
        let menu2 = HSMenu(icon: nil, title: "Configurações")
        let menu3 = HSMenu(icon: nil, title: "Sair")
        
        menuArray = [menu1, menu2, menu3]
        
        
        //btnMenu.addTarget(self, action: #selector(popMenu1), for: .touchUpInside)

    }
    
    func popMenu1() {
        let popupMenu = HSPopupMenu(menuArray: menuArray, arrowPoint: CGPoint(x: UIScreen.main.bounds.width-35, y: 64))
        popupMenu.popUp()
        popupMenu.delegate = self
    }

    func popupMenu(_ popupMenu: HSPopupMenu, didSelectAt index: Int) {
        //print("selected index is: " + "\(index)")
        
        if (index == 2) {
            
            logout()
            
        }
        
    }
    
    func logout() {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        loginManager.logOut()
        
        AppService.util.removeUserDataFromUserDefaults()
        
        
        //performSegue(withIdentifier: "goto_primeira", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "PrimeiraVC")
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func clickMenu(_ sender: Any) {
        
        popMenu1()
        
    }
    

}
