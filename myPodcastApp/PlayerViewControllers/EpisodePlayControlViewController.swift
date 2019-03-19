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
    @IBOutlet weak var slider: CustomUISlider!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var episodeAuthor: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var speedEdt: UITextField!
    
    var speedPicker: UIPickerView!
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
        var speedString = String(format: "%.2f", preferedSpeed)
        speedString += "x"
        self.speedEdt.text = speedString
        self.speedEdt.layer.borderWidth = 1
        self.speedEdt.layer.cornerRadius = 10
        self.speedEdt.layer.borderColor = UIColor.black.cgColor
        speedEdt.delegate = self
        speedPicker = UIPickerView()
        speedPicker.dataSource = self
        speedPicker.delegate = self
        speedEdt.inputView = speedPicker
        
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
    
    @IBAction func clickDownload(_ sender: Any) {
    }
    
    @IBAction func clickMore(_ sender: Any) {
    }
    
//    @IBAction func clickSpeedBtn(_ sender: Any) {
//        // get a reference to the view controller for the popover
//
//        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "playerRateViewController")
//
//        // set the presentation style
//        popController.modalPresentationStyle = UIModalPresentationStyle.popover
//
//        // set up the popover presentation controller
//        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
//        popController.popoverPresentationController?.delegate = self
//        popController.popoverPresentationController?.sourceView = sender as! UIView // button
//        popController.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
//
//        // present the popover
//        self.present(popController, animated: true, completion: nil)
//    }
    
    
}

extension EpisodePlayControlViewController: UIPopoverPresentationControllerDelegate {
    
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
        
        let progressSeconds = playerManager.shared.getEpisodeCurrentTimeInSeconds()
        let durationSeconds = playerManager.shared.getEpisodeDurationInSeconds()

        let remainingSeconds = durationSeconds - progressSeconds
        self.remainingLabel.text = Util.convertSecondsToDateString(seconds: remainingSeconds)
        
        self.progressLabel.text = Util.convertSecondsToDateString(seconds: progressSeconds)
        
        slider.maximumValue = Float(durationSeconds)
        slider.value = Float(progressSeconds)
    }
}

extension EpisodePlayControlViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return speedArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return speedArray[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedSpeed = speedArray[row]
        let myRate: Float?
        switch selectedSpeed {
            case playerSpeed.speed_1:
                myRate = 1.0
            
            case playerSpeed.speed_1_5:
                myRate = 1.5

            case playerSpeed.speed_1_75:
                myRate = 1.75

            case playerSpeed.speed_2:
                myRate = 2.0

        }
        playerManager.shared.changePlaybackRate(rate: myRate!)
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set(myRate, forKey: "preferedSpeed")
        speedEdt.text = selectedSpeed.rawValue
        self.view.endEditing(true)
    }
    
    
}

