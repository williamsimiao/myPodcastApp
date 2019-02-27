//
//  LeituraViewController.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class LeituraViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    var episodeTitle: String?
    var author: String?
    var resumoText: String?
    var textSettingsButton : UIBarButtonItem?
    var lightModeButton : UIBarButtonItem?
    var darkModeButton : UIBarButtonItem?

    var textSettingsIsActive = false
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
//        if (bottomEdge >= scrollView.contentSize.height) {
//            print("FIM")
//        }
//    }

}
