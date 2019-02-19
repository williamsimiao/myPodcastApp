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
    
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Properties
    var currentPlayButtonState : playButtonStates?
    weak var delegate: updateMiniPlayerDelegate?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if playerManager.shared.getPlayerIsSet() {
            configureFields()
        }
        else {
//            setFieldsBlank()
        }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEpisodeDidChange(_:)), name: .episodeDidChange, object: playerManager.shared)
    }
    
    func setFieldsBlank() {
        self.episodeTitle.text = "-"
        self.remainingLabel.text = "-"
        self.episodeAuthor.text = "-"
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
    
    @IBAction func rewindAction(_ sender: Any) {
        playerManager.shared.rewind()

    }
    
    
    @IBAction func sliderTouchUpInside(_ sender: Any) {
        let jump = self.slider.value
        playerManager.shared.jumpTo(seconds: Double(jump))
    }
    
    
    @IBAction func forwardAction(_ sender: Any) {
        playerManager.shared.foward()

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

// MARK: - Song Extension
extension Resumo {
    
//    var presentationTime: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "mm:ss"
//        let date = Date(timeIntervalSince1970: duration)
//        return formatter.string(from: date)
//    }
}

// MARK: - Player dataSource
extension EpisodePlayControlViewController {
    @objc func onPlayerTimeDidProgress(_ notification: Notification) {
        if let data = notification.userInfo as? [String: Double] {
            for (_, value) in data {
                self.slider.maximumValue = Float(playerManager.shared.getEpisodeDurationInSeconds())
                let remainingTime = Double(self.slider.maximumValue) - value
                self.remainingLabel.text = Util.convertSecondsToDateString(seconds: remainingTime)
                
                self.progressLabel.text = Util.convertSecondsToDateString(seconds: value)
                
                self.slider.value = Float(value)
            }
        }
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
    
    @objc func onEpisodeDidChange(_ notification: Notification) {
        configureFields()
    }
    
    func configureFields() {
        let title  = playerManager.shared.getEpisodeTitle()
        self.episodeTitle.text = title
        self.episodeAuthor.text = playerManager.shared.getEpisodeAuthor()
        
        let seconds = playerManager.shared.getEpisodeDurationInSeconds()
        self.slider.maximumValue = Float(seconds)
        self.slider.value = Float(playerManager.shared.getEpisodeCurrentTimeInSeconds())
        
        //TODO: change this images
        self.slider.setThumbImage(UIImage(named: "thumbDefault"), for: UIControl.State.normal)
        self.slider.setThumbImage(UIImage(named: "thumbSelected"), for: UIControl.State.highlighted)
        self.remainingLabel.text = Util.convertSecondsToDateString(seconds: seconds)
    }
}

