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
    func expandEpisode()
}

class MiniPlayerViewController: UIViewController {
    
    // MARK: - Properties
    weak var expandDelegate: MiniPlayerDelegate?
    //Initial State mast match the Storyboard
    var currentPlayButtonState = playButtonStates.play

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayingStateDidChange(_:)), name: .playingStateDidChange, object: playerManager.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEpisodeDidChange(_:)), name: .episodeDidChange, object: playerManager.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayerTimeDidProgress(_:)), name: .playerTimeDidProgress, object: playerManager.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFullPlayerShouldAppear(_:)), name: .fullPlayerShouldAppear, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(onPlayerIsSetUp(_:)), name: .playerIsSetUp, object: nil)

    }
    
    
    @IBAction func clickClose(_ sender: Any) {
        playerManager.shared.player?.pause()
        self.contentView.isHidden = true
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
        self.expandDelegate?.expandEpisode()
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

// MARK: - Player dataSource
extension MiniPlayerViewController {
    @objc func onPlayingStateDidChange(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Bool] {
            //for (key, value)
            for (_, isPlaying) in data {
                //TODO: replace for a animation instead
                if isPlaying && self.currentPlayButtonState != .pause {
                    changeButtonState(to: .pause)
                }
                else if !isPlaying && self.currentPlayButtonState == .pause {
                    changeButtonState(to: .play)
                }
            }
        }
    }
    
    @objc func onEpisodeDidChange(_ notification: Notification) {
        self.contentView.isHidden = false
        let title = playerManager.shared.getEpisodeTitle()
        let imageURL = playerManager.shared.getEpisodeCoverImgUrl()
        Network.setCoverImgWithPlaceHolder(imageUrl: imageURL, theImage: self.coverImg)
        self.titleLabel.text = title
        
    }
    
    @objc func onPlayerTimeDidProgress(_ notification: Notification) {
        let duration = playerManager.shared.getEpisodeDurationInSeconds()
        let currentTime = playerManager.shared.getEpisodeCurrentTimeInSeconds()
        let razao = currentTime/duration
        self.progressBar.progress = Float(razao)
    }
    
    @objc func onFullPlayerShouldAppear(_ notification: Notification) {
        self.expandDelegate?.expandEpisode()
    }
    
    @objc func onPlayerIsSetUp(_ notification: Notification) {
        self.contentView.isHidden = false
        let height = self.view.frame.size.height
        playerManager.shared.miniContainerFrameHight = height
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


