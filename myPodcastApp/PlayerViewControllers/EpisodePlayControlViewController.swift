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
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - Properties
    var currentPlayButtonState = playButtonStates.pause
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
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayingStateDidChange(_:)), name: .playingStateDidChange, object: playerManager.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if playerManager.shared.getIsPlaying() {
            if let pauseImg = UIImage(named: "pause_48") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        else {
            if let playImg = UIImage(named: "play_48") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
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
            if let pauseImg = UIImage(named: "pause_48") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
            //the negation is true
        else {
            currentPlayButtonState = playButtonStates.play
            if let playImg = UIImage(named: "play_48") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func rewind_action(_ sender: Any) {
        playerManager.shared.rewind()
    }
    
    @IBAction func play_action(_ sender: Any) {
        if self.currentPlayButtonState == .pause {
            playerManager.shared.playPause(shouldPlay: true)
        }
        else {
            playerManager.shared.playPause(shouldPlay: false)
        }
    }
    @IBAction func forward_action(_ sender: Any) {
        playerManager.shared.foward()
    }
}

// MARK: - Internal
extension EpisodePlayControlViewController {
    
    func configureFields() {
        guard songTitle != nil else {
            return
        }
        
        songTitle.text = currentSong?.title
        songDuration.text = "Duration \(currentSong?.presentationTime ?? "")"
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
