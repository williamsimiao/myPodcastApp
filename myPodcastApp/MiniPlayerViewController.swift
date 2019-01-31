//
//  MiniPlayerViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation

protocol MiniPlayerDelegate: class {
    func expandEpisode(episode: Episode)
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - Properties
    var currentEpisode: Episode?
    weak var delegate: MiniPlayerDelegate?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerManager.shared.delegate = self
    }
}
// MARK: - IBActions
extension MiniPlayerViewController {
    @IBAction func contentViewTapAction(_ sender: Any) {
        guard let episode = currentEpisode else {
            return
        }
        delegate?.expandEpisode(episode: episode)
    }
    
    @IBAction func playAction(_ sender: Any) {
        print(playerManager.shared.getIsPlaying())
        playerManager.shared.play()
    }
}

// MARK: - playerUIDelegate
extension MiniPlayerViewController: playerUIDelegate {
    func coverChanged(imageURL: String) {
        Network.setCoverImgWithPlaceHolder(imageUrl: imageURL, theImage: self.coverImg)
    }
    
    func playingStateChanged(toPause: Bool) {
        if toPause {
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        else {
            if let playImg = UIImage(named: "playBranco_36") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
    }
    
    func titleChanged(title: String) {
        self.title = title
    }
}
