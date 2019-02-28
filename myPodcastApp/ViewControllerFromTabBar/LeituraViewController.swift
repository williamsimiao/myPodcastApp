//
//  LeituraViewController.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class LeituraViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var parabensLabel: UILabel!
    @IBOutlet weak var avaliarLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    
    var episodeTitle: String?
    var author: String?
    var resumoText: String?
    var textSettingsButton : UIBarButtonItem?
    var lightModeButton : UIBarButtonItem?
    var darkModeButton : UIBarButtonItem?
    var starArray: [UIButton]?

    var textSettingsIsActive = false
    override func viewDidLoad() {
        super.viewDidLoad()
        starArray = [star1, star2, star3, star4, star5]
        textSettingsButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeituraViewController.clickTextSettings(_:)))
        textSettingsButton!.setBackgroundImage(UIImage(named: "textSettingsOff"), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
//
//        lightModeButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeituraViewController.clickLightMode(_:)))
//        lightModeButton!.setBackgroundImage(UIImage(named: "lightMode"), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
//
//        darkModeButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(LeituraViewController.clickDarkMode(_:)))
//        darkModeButton!.setBackgroundImage(UIImage(named: "darkMode"), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
        
//        textSettingsButton = UIBarButtonItem.menuButton(self, action: #selector(LeituraViewController.clickTextSettings(_:)), imageName: "textSettingsOff")
        
        self.navigationItem.setRightBarButtonItems([textSettingsButton!], animated: true)
        
        scrollView.delegate = self
        tittleLabel.text = episodeTitle
        authorLabel.text = author
        textView.text = resumoText
        textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        textView.textAlignment = NSTextAlignment.justified
    }
    override func viewWillAppear(_ animated: Bool) {
        resetMenuApperence()
    }
    
    func resetMenuApperence() {
        textSettingsIsActive = false
        lightModeButton?.isHidden = false
        darkModeButton?.isHidden = false
        //TODO: Make the ajust view disapier
    }

    @objc func clickTextSettings(_ sender: UIBarButtonItem) {
        if !textSettingsIsActive {
            textSettingsIsActive = true
            sender.setBackgroundImage(UIImage(named: "textSettingsOn"), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
            
            lightModeButton?.isHidden = false
            darkModeButton?.isHidden = false
        }
        else {
            textSettingsIsActive = false
            sender.setBackgroundImage(UIImage(named: "textSettingsOff"), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
            
            lightModeButton?.isHidden = true
            darkModeButton?.isHidden = true
        }
    }
    
    @objc func clickLightMode(_ sender: UIBarButtonItem) {
        sender.tintColor = ColorWeel().orangeColor
        darkModeButton?.tintColor = .gray
        //TODO: Change text and background color
    }
    
    @objc func clickDarkMode(_ sender: UIBarButtonItem) {
        sender.tintColor = ColorWeel().orangeColor
        lightModeButton?.tintColor = .gray
        //TODO: Change text and background color
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio = scrollView.contentOffset.y/(scrollView.contentSize.height - scrollView.frame.size.height)
        progressView.progress = Float(ratio)
    }
    
    @IBAction func tapStar(_ sender: Any) {
        let senderStar = sender as! UIButton
        let index: Int
        switch senderStar {
        case self.star1:
            index = 1
        case self.star2:
            index = 2
        case self.star3:
            index = 3
        case self.star4:
            index = 4
        case self.star5:
            index = 5
        default:
            return
        }
        //Coloring until the taped one
        for i in 0..<index {
            let currentStar = starArray![i]
            currentStar.setImage(UIImage(named: "starBig"), for: UIControl.State.normal)
        }
        //Discoloring the others
        for i in index..<(starArray?.count)! {
            let currentStar = starArray![i]
            currentStar.setImage(UIImage(named: "starBigBlanck"), for: UIControl.State.normal)
        }
    }
    

}
