//
//  ViewController.swift
//  myPodcastApp
//
//  Created by William on 21/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func add_url(_ sender: Any) {
        StreamingFeature.init(viewController: self).importFunc()
    }
    
    @IBAction func back_button(_ sender: Any) {
        
    }
    
    @IBAction func play_button(_ sender: Any) {
    }
    
    @IBAction func foward_button(_ sender: Any) {
    
    }
    

}

