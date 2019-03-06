//
//  RecuperarViewController.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class RecuperarViewController: UIViewController {

    @IBOutlet weak var btnRecuperar: UIButton!
    @IBOutlet weak var blackBox: UIView!
    @IBOutlet weak var edtEmail: CadastroTextField!
    var radius = CGFloat(20)
    override func viewDidLoad() {
        super.viewDidLoad()
        blackBox.layer.cornerRadius = radius
        btnRecuperar.layer.cornerRadius = 20
        btnRecuperar.clipsToBounds = true
        btnRecuperar.layer.borderWidth = 1
        btnRecuperar.layer.borderColor = ColorWeel().orangeColor.cgColor
    }
    
    @IBAction func clickClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func clickRecuperar(_ sender: Any) {
        //TODO: Call API
    }
}
