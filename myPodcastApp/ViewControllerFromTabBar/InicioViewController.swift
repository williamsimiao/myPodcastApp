//
//  InicioViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InicioViewController: InheritanceViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var episodesArray : [String:AnyObject]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSubView()
        self.view.layoutIfNeeded()
        
        //getting Data
        
        
    }
}

extension InicioViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        return cell
    }
}

