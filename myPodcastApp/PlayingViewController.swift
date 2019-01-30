//
//  PlayingViewController.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage

class PlayingViewController: UIViewController, playerUIDelegate {
    
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fowardButton: UIButton!
    var imageUrl = String()
    var player:AVPlayer?
    let valor = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descriptionText.isEditable = false
        
        if playerManager.shared.getIsPlaying() {
            if let pauseImg = UIImage(named: "pause_48") {
                playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        } else {
            if let playImg = UIImage(named: "play_48") {
                playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
        DispatchQueue.global(qos: .background).async {
            while playerManager.shared.getIsPlaying() {}
            DispatchQueue.main.async {
                if let pauseImg = UIImage(named: "pause_48") {
                    self.playButton.setImage(pauseImg, for: UIControl.State.normal)
                }
            }
        }
        self.playButton.isEnabled = false
        self.fowardButton.isEnabled = false
        self.backButton.isEnabled = false
        DispatchQueue(label: "WaitMP3").async {
            while !playerManager.shared.getIsPlaying() {}
            DispatchQueue.main.async {
                self.playButton.isEnabled = true
                self.fowardButton.isEnabled = true
                self.backButton.isEnabled = true
            }
        }
    }
    
    @IBAction func back_action(_ sender: Any) {
        playerManager.shared.rewind()
    }
    
    @IBAction func play_action(_ sender: Any) {
        switch playerManager.shared.getIsPlaying() {
        case true:
            if let playImg = UIImage(named: "play_48") {
                playButton.setImage(playImg, for: UIControl.State.normal)
            }
            
        default:
            if let pauseImg = UIImage(named: "pause_48") {
                playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        playerManager.shared.play()
    }
    
    @IBAction func foward_action(_ sender: Any) {
        playerManager.shared.foward()
    }
    
    //MARK - playerUIDelegate
    func coverChanged(imageURL: String) {
        Util.setCoverImgWithPlaceHolder(imageUrl: imageURL, theImage: self.coverImg)
    }
    
    func playingStateChanged(isPlaying: Bool) {
        
    }
    
    func titleChanged(title: String) {
        
    }
}
