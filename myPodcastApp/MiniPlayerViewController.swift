//
//  MiniPlayerViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation

enum playButtonStates {
    case play
    case pause
}

protocol MiniPlayerDelegate: class {
    func expandEpisode(coverImg: UIImage)
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: MiniPlayerDelegate?
    //Initial State mast match the Storyboard
    var currentPlayButtonState = playButtonStates.pause

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
        self.delegate?.expandEpisode(coverImg: self.coverImg.image!)
    }
    
    @IBAction func playAction(_ sender: Any) {
        if self.currentPlayButtonState == playButtonStates.play {
            currentPlayButtonState = playButtonStates.pause
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
                playerManager.shared.playPause(shouldPlay: true)
            }
        }
        else {
            currentPlayButtonState = playButtonStates.play
            if let playImg = UIImage(named: "playBranco_36") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
                playerManager.shared.playPause(shouldPlay: false)
            }
        }
    }
}

// MARK: - playerUIDelegate
extension MiniPlayerViewController: playerUIDelegate {
    func coverChanged(imageURL: String) {
        Network.setCoverImgWithPlaceHolder(imageUrl: imageURL, theImage: self.coverImg)
    }
    
    func titleChanged(title: String) {
        self.titleLabel.text = title
    }
}

// MARK: -
extension MiniPlayerViewController: PlayerCardSourceProtocol {
    var originatingFrameInWindow: CGRect {
        let windowRect = view.convert(view.frame, to: nil)
        return windowRect
    }
    
    var originatingCoverImageView: UIImageView {
        return self.coverImg
    }
}


