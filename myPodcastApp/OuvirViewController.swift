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

class OuvirViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var resizableViewBottonConstrain: NSLayoutConstraint!
    var miniContainerHeight : CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateSize()
        
    }
    
    func updateSize() {
        self.resizableViewBottonConstrain.constant += miniContainerHeight!
    }
}

