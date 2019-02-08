//
//  EpisodePlayControlViewController.swift
//  myPodcastApp
//
//  Created by William on 01/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol updateMiniPlayerDelegate : class {
    func updateMiniPlayer()
}

class EpisodePlayControlViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeAuthor: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var previusButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    // MARK: - Properties
    var currentPlayButtonState : playButtonStates?
    weak var delegate: updateMiniPlayerDelegate?
    

    var currentSong: Episode? {
        didSet {
            configureFields()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFields()
        //Config button initial state
        if self.currentPlayButtonState == .pause {
            if let pauseImg = UIImage(named: "pause") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        else if self.currentPlayButtonState == .play {
            if let playImg = UIImage(named: "play") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayingStateDidChange(_:)), name: .playingStateDidChange, object: playerManager.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayerTimeDidProgress(_:)), name: .playerTimeDidProgress, object: playerManager.shared)
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
                if let pauseImg = UIImage(named: "pause") {
                    self.playButton.setImage(pauseImg, for: UIControl.State.normal)
                }
            }
            else if state == .play {
                currentPlayButtonState = playButtonStates.play
                if let playImg = UIImage(named: "play") {
                    self.playButton.setImage(playImg, for: UIControl.State.normal)
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func rewind_action(_ sender: Any) {
        playerManager.shared.rewind()
    }
    @IBAction func slider_touchUp_inside(_ sender: Any) {
        let jump = self.slider.value
        playerManager.shared.jumpTo(seconds: Double(jump))

    }
    
    @IBAction func play_action(_ sender: Any) {
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
    @IBAction func forward_action(_ sender: Any) {
        playerManager.shared.foward()
    }
    
    
    
}

// MARK: - Internal
extension EpisodePlayControlViewController {
    
    func configureFields() {
        let seconds = playerManager.shared.getEpisodeDurationInSeconds()
        self.slider.maximumValue = Float(seconds)
        self.slider.value = Float(playerManager.shared.getEpisodeCurrentTimeInSeconds())
        self.remainingLabel.text = Util.convertSecondsToDateString(seconds: seconds)
    }
}

// MARK: - Song Extension
extension Episode {
    
    var presentationTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let date = Date(timeIntervalSince1970: duration)
        return formatter.string(from: date)
    }
}

// MARK: - Song Extension notification Center
extension EpisodePlayControlViewController {
    @objc func onPlayerTimeDidProgress(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Double] {
            for (_, value) in data {
                let remainingTime = playerManager.shared.getEpisodeDurationInSeconds() - value
                self.remainingLabel.text = Util.convertSecondsToDateString(seconds: remainingTime)
                
                self.progressLabel.text = Util.convertSecondsToDateString(seconds: value)
                
                self.slider.value = Float(value)
            }
        }
    }
}

