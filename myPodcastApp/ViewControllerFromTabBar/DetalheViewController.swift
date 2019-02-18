//
//  DetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class DetalheViewController: InheritanceViewController {
    
    @IBOutlet weak var episodeContentView: epidodeContentRightView!
    
    @IBOutlet weak var FortyMinutesView: UIView!
    @IBOutlet weak var TenMinutesView: UIView!
    
    
    
    var selectedEpisode : [String: AnyObject]?
    var selectedEpisodeImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        episodeContentView.delegate = self
        setupUI()
    }
    
    @IBAction func fortyPlayButtonAction(_ sender: Any) {
        playerManager.shared.episodeSelected(episodeDictionary: selectedEpisode!)
        
        //expand
        
    }
    
    @IBAction func tenPlayButtonAction(_ sender: Any) {
        
    }
    
    func setupUI() {
        let titulo =  self.selectedEpisode!["titulo"] as! String
        self.episodeContentView.titleLabel.text = titulo
        let authorsList = self.selectedEpisode!["autores"] as! [[String : AnyObject]]
        let joinedNames =  Util.joinStringWithSeparator(authorsList: authorsList, separator: " & ")
        self.episodeContentView.authorLabel.text = joinedNames
        self.episodeContentView.coverImg.image = self.selectedEpisodeImage
        
        self.FortyMinutesView.layer.borderWidth = 1
        self.FortyMinutesView.layer.borderColor = UIColor.white.cgColor
        self.FortyMinutesView.layer.cornerRadius = 10

        self.TenMinutesView.layer.borderWidth = 1
        self.TenMinutesView.layer.borderColor = UIColor.white.cgColor
        self.TenMinutesView.layer.cornerRadius = 10
    }
}

extension DetalheViewController: contentViewDelegate {
    func viewClicked() {
    }
}

//MARK - buttons
extension DetalheViewController {
    
}

