//
//  playerManager.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import AVFoundation

class playerManager {
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    let valor = 5
    
    func foward() {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(valor), preferredTimescale: currentTime!.timescale)
        player?.seek(to: jump)
    }
}
