//
//  MiniPlayerViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

enum playButtonStates {
    case play
    case pause
}

protocol MiniPlayerDelegate: class {
    func expandEpisode(miniPLayer: MiniPlayerViewController)
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - Properties
    weak var expandDelegate: MiniPlayerDelegate?
    //Initial State mast match the Storyboard
    var currentPlayButtonState = playButtonStates.pause

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayingStateDidChange(_:)), name: .playingStateDidChange, object: playerManager.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        playerManager.shared.delegate = self
    }
    
    @objc func onPlayingStateDidChange(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            for (key, isPlaying) in data {
                changeButtonState(isPlaying: isPlaying)
            }
        }
    }
    
    func changeButtonState(isPlaying:Bool) {
        if isPlaying {
            // IF is playing then the button must be pause
            currentPlayButtonState = playButtonStates.pause
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        //the negation is true
        else {
            currentPlayButtonState = playButtonStates.play
            if let playImg = UIImage(named: "playBranco_36") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
    }
}
// MARK: - IBActions
extension MiniPlayerViewController {
    @IBAction func contentViewTapAction(_ sender: Any) {
        self.expandDelegate?.expandEpisode(miniPLayer: self)
    }
    
    @IBAction func playAction(_ sender: Any) {
        if self.currentPlayButtonState == .pause {
            playerManager.shared.playPause(shouldPlay: true)
        }
        else {
            playerManager.shared.playPause(shouldPlay: false)
        }
    }
}

// MARK: - playerUIDelegate
extension MiniPlayerViewController: episodeDataSourceProtocol {
    func episodeDataChangedTo(imageURL:String, title:String) {
        Network.setCoverImgWithPlaceHolder(imageUrl: imageURL, theImage: self.coverImg)
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


