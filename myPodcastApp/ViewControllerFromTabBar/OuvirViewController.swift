//
//  OuvirViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class OuvirViewController: InheritanceViewController {
    // MARK: - Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resizableView = (UINib(nibName: "ouvirView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView)
        self.setupSubView()
        
//        self.updateContrain(constrain: resizableViewBottonConstrain)
    }
}

