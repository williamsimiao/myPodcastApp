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
    @IBOutlet weak var resizableView: UIView!
    
    @IBOutlet weak var resizableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var resumoView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    var exempleText = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        self.superResizableView = resizableView
        self.superBottomConstraint = resizableBottomConstraint
        
        episodeContentView.delegate = self

        setupUI()
    }
    
    @IBAction func fortyPlayButtonAction(_ sender: Any) {
        //Play the episode
        playerManager.shared.episodeSelected(episodeDictionary: selectedEpisode!)
        
        NotificationCenter.default.post(name: .fullPlayerShouldAppear, object: self, userInfo: nil)
//        NotificationCenter.default.post(name: .fullPlayerShouldAppear, object: self, userInfo: nil)

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
        self.FortyMinutesView.backgroundColor = .black
        self.FortyMinutesView.layer.borderColor = UIColor.white.cgColor
        self.FortyMinutesView.layer.cornerRadius = 10

        self.TenMinutesView.layer.borderWidth = 1
        self.TenMinutesView.backgroundColor = .black
        self.TenMinutesView.layer.borderColor = UIColor.white.cgColor
        self.TenMinutesView.layer.cornerRadius = 10
        
        self.resumoView.layer.cornerRadius = 10
        self.textView.text = self.exempleText
        self.textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        self.textView.textAlignment = NSTextAlignment.justified

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let leituraVC = segue.destination as? LeituraViewController {
            let authorsList = self.selectedEpisode!["autores"] as! [[String : AnyObject]]
            let joinedNames =  Util.joinStringWithSeparator(authorsList: authorsList, separator: " & ")
            
            leituraVC.author = joinedNames
            leituraVC.episodeTitle = (self.selectedEpisode!["titulo"] as! String)
            leituraVC.resumoText = exempleText
        }

    }
    @IBAction func clickORSwipeUp(_ sender: Any) {
        
        performSegue(withIdentifier: "goto_leitura", sender: self)
    }
    
}

extension DetalheViewController: contentViewDelegate {
    func viewClicked() {
    }
}

//MARK - buttons
extension DetalheViewController {
    
}

