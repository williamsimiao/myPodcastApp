//
//  EpisodePlayControlViewController.swift
//  myPodcastApp
//
//  Created by William on 01/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class EpisodePlayControlViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    
    // MARK: - Properties
    var currentSong: Episode? {
        didSet {
            configureFields()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFields()
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
