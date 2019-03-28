//
//  EditarPerfilViewController.swift
//  myPodcastApp
//
//  Created by William on 18/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class EditarPerfilViewController: UIViewController {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var edtNome: CadastroTextField!
    @IBOutlet weak var edtSobrenome: CadastroTextField!
    
    @IBOutlet weak var edtTelefone: CadastroTextField!
    @IBOutlet weak var edtNascimento: CadastroTextField!
    
    @IBOutlet weak var edtSexo: CadastroTextField!
    
    @IBOutlet weak var edtEscolaridade: CadastroTextField!
    @IBOutlet weak var edtEmail: CadastroTextField!
    
    @IBOutlet weak var edtSenha: CadastroTextField!
    
    @IBOutlet weak var btnEmpreende: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickAtualizar(_ sender: Any) {
        self.dismiss(animated: true) {
            print("Salvando alterações")
        }
    }
}

//Get user data from user
extension EditarPerfilViewController {
    
}
