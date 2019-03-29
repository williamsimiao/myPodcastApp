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

enum playerSpeed : String {
    case speed_1 = "1x"
    case speed_1_5 = "1.5x"
    case speed_1_75 = "1.75x"
    case speed_2 = "2x"
}

class EpisodePlayControlViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeAuthor: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var speedBtn: UIButton!
    
    var sliderIsInUse = false
    let speedArray = [playerSpeed.speed_1, playerSpeed.speed_1_5, playerSpeed.speed_1_75, playerSpeed.speed_2]
    
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
        let prefs:UserDefaults = UserDefaults.standard
        var preferedSpeed = prefs.float(forKey: "preferedSpeed")
        if preferedSpeed == 0 {
            preferedSpeed = 1.0
            prefs.set(1.0, forKey: "preferedSpeed")
        }
        
        let speedString = findSpeedString(speed: preferedSpeed)
        self.speedBtn.setTitle(speedString, for: .normal)
        self.speedBtn.layer.borderWidth = 1
        self.speedBtn.layer.cornerRadius = 10
        self.speedBtn.layer.borderColor = UIColor.black.cgColor
        
        playerManager.shared.changePlaybackRate(rate: preferedSpeed)
        
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
    
    @IBAction func sliderTouchDown(_ sender: Any) {
        self.sliderIsInUse = true
    }
    
    
    
    @IBAction func sliderTouchUpInside(_ sender: Any) {
        changeAudioPositionAndUI()
    }
    
    @IBAction func sliderTouchUpOutSide(_ sender: Any) {
        changeAudioPositionAndUI()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        let remainingTime = Double(self.slider.maximumValue) - Double(slider.value)
        self.remainingLabel.text = Util.convertSecondsToDateString(seconds: remainingTime)
        
        self.progressLabel.text = Util.convertSecondsToDateString(seconds: Float64(slider!.value))
    }
    
    func changeAudioPositionAndUI() {
        self.sliderIsInUse = false
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
    
    @IBAction func clickDownload(_ sender: Any) {
    }
    
    @IBAction func clickMore(_ sender: Any) {
        let resumoLink = playerManager.shared.getResumoLink()
        let vc = UIActivityViewController(activityItems: [resumoLink], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func setNewSpeed(selectedSpeed: playerSpeed) {
        let rate = findSpeedFloat(selectedSpeed: selectedSpeed.rawValue)
        playerManager.shared.changePlaybackRate(rate: rate)
        
        speedBtn.setTitle(selectedSpeed.rawValue, for: .normal)
        
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set(rate, forKey: "preferedSpeed")
    }

    
    @IBAction func clickSpeedBtn(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Escolha uma velocidade", preferredStyle: .actionSheet)
        
        let action_1 = UIAlertAction(title: "1x", style: .default) { _ in
            self.setNewSpeed(selectedSpeed: playerSpeed.speed_1)
        }
        
        let action_1_5 = UIAlertAction(title: "1.5x", style: .default) { _ in
            self.setNewSpeed(selectedSpeed: playerSpeed.speed_1_5)
        }
        let action_1_75 = UIAlertAction(title: "1.75x", style: .default) { _ in
            self.setNewSpeed(selectedSpeed: playerSpeed.speed_1_75)
        }
        let action_2 = UIAlertAction(title: "2x", style: .default) { _ in
            self.setNewSpeed(selectedSpeed: playerSpeed.speed_2)
        }
        
        optionMenu.addAction(action_1)
        optionMenu.addAction(action_1_5)
        optionMenu.addAction(action_1_75)
        optionMenu.addAction(action_2)
        
        self.present(optionMenu, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            optionMenu.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
}

// MARK: - Player dataSource
extension EpisodePlayControlViewController {
    @objc func onPlayerTimeDidProgress(_ notification: Notification) {
        if self.sliderIsInUse == false {
            if let data = notification.userInfo as? [String: Double] {
                var durationSeconds = 0.0
                var currentSeconds = 0.0
                for (key, value) in data {
                    if key == "currentTime" {
                        currentSeconds = value
                    }
                    if key == "duration" {
                        durationSeconds = value
                    }
                }
                self.slider.maximumValue = Float(durationSeconds)
                var remainingSeconds = durationSeconds - currentSeconds
                
                if remainingSeconds <= 0.0 {
                    remainingSeconds = 0.0
                    currentSeconds = durationSeconds
                }
                self.remainingLabel.text = Util.convertSecondsToDateString(seconds: remainingSeconds)
                self.progressLabel.text = Util.convertSecondsToDateString(seconds: currentSeconds)
                self.slider.value = Float(currentSeconds)
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
        
        let progressSeconds = playerManager.shared.getEpisodeCurrentTimeInSeconds()
        let durationSeconds = playerManager.shared.getEpisodeDurationInSeconds()

        let remainingSeconds = durationSeconds - progressSeconds
        self.remainingLabel.text = Util.convertSecondsToDateString(seconds: remainingSeconds)
        
        self.progressLabel.text = Util.convertSecondsToDateString(seconds: progressSeconds)
        
        slider.maximumValue = Float(durationSeconds)
        slider.value = Float(progressSeconds)
    }
}

//HELper functions
extension EpisodePlayControlViewController {
    func findSpeedString(speed: Float) -> String {
        if speed == 1.0 {
            return playerSpeed.speed_1.rawValue
        }
        else if speed == 1.5 {
            return playerSpeed.speed_1_5.rawValue
        }
        else if speed == 1.75 {
            return playerSpeed.speed_1_75.rawValue
        }
        else if speed == 2.0 {
            return playerSpeed.speed_2.rawValue
        }
        return playerSpeed.speed_1.rawValue
    }
    
    func findSpeedFloat(selectedSpeed: String) -> Float {
        let myRate: Float?
        
        switch selectedSpeed {
        case playerSpeed.speed_1.rawValue:
            myRate = 1.0
            
        case playerSpeed.speed_1_5.rawValue:
            myRate = 1.5
            
        case playerSpeed.speed_1_75.rawValue:
            myRate = 1.75
            
        case playerSpeed.speed_2.rawValue:
            myRate = 2.0
            
        default:
            myRate = 1.0
        }
        return myRate!
    }
}

