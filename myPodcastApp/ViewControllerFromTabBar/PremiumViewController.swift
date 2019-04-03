//
//  PremiumViewController.swift
//  myPodcastApp
//
//  Created by William on 29/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class PremiumViewController: UIViewController {

    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var blackBox: UIView!
    
    let radius:CGFloat = 20.0
    override func viewDidLoad() {
        super.viewDidLoad()
        okBtn.layer.cornerRadius = radius
        blackBox.layer.cornerRadius = radius

    }
    
    @IBAction func clickOK(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
