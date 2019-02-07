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
    var currentPlayButtonState = playButtonStates.play

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
            for (_, isPlaying) in data {
                if isPlaying && self.currentPlayButtonState != .pause {
                    changeButtonState(to: .pause)
                }
                else if !isPlaying && self.currentPlayButtonState == .pause {
                    changeButtonState(to: .play)
                }
            }
        }
    }
    
    func changeButtonState(to state:playButtonStates) {
        if state != self.currentPlayButtonState {
            if state == .pause {
                currentPlayButtonState = playButtonStates.pause
                if let pauseImg = UIImage(named: "miniPause") {
                    self.playButton.setImage(pauseImg, for: UIControl.State.normal)
                }
            }
            else if state == .play {
                currentPlayButtonState = playButtonStates.play
                if let playImg = UIImage(named: "miniPlay") {
                    self.playButton.setImage(playImg, for: UIControl.State.normal)
                }
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
        //User pressed PLAY
        if self.currentPlayButtonState == .play {
            playerManager.shared.playPause(shouldPlay: true)
            changeButtonState(to: .pause)
        }
        //User pressed pause
        else {
            playerManager.shared.playPause(shouldPlay: false)
            changeButtonState(to: .play)
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


