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

class PlayingViewController: UIViewController {
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

        let url = URL(string:self.imageUrl)!
        let placeholderImage = UIImage(named: "cover_placeholder")!
        
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: self.coverImg.frame.size,
            radius: 20.0
        )
        
        self.coverImg.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage,
            filter: filter
        )
        
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
            while playerManager.shared.player?.rate == 0 {}
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
