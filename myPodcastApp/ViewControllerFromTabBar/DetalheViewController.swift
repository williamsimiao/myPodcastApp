//
//  DetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class DetalheViewController: UIViewController {

    @IBOutlet weak var episodeContentView: epidodeContentRightView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension DetalheViewController: episodeSelectedDelegate {
    func episodeSelected(episode: [String : AnyObject], episodeCover: UIImage) {
        
        self.episodeContentView.titleLabel.text = (episode["titulo"] as! String)
        let authorsList = episode["autores"] as! [[String : AnyObject]]
        let joinedNames =  Util.joinStringWithSeparator(authorsList: authorsList, separator: " & ")
        self.episodeContentView.authorLabel.text = joinedNames
    }
}
