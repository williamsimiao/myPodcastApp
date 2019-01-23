//
//  playerManager.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


class playerManager {
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    let valor = 5
    var currentEpisodeId:String?
    private var playerIsSet = false
    static let shared = playerManager()
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    private init() {}
    
    func getPlayerIsSet() -> Bool{
        return self.playerIsSet
    }
    
    func getIsPlaying() -> Bool {
        if self.player?.rate != 0 {
            return true
        } else {
            return false
        }
    }
    
    func player_setup(episodeId:String, motherView:UIView, mPlayerItem:AVPlayerItem) {
        self.currentEpisodeId = episodeId
        self.playerIsSet = true
        
        self.player = AVPlayer(playerItem: mPlayerItem)
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
        motherView.layer.addSublayer(playerLayer)
        
        self.player?.play()
    }
    
    func changePlayingEpisode(episodeId:String, mPlayerItem:AVPlayerItem) {
        if self.currentEpisodeId != episodeId {
            self.player?.pause()
            self.currentEpisodeId = episodeId
            
            self.player?.replaceCurrentItem(with: mPlayerItem)
        }
    }
    
    func foward() {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(valor), preferredTimescale: currentTime!.timescale)
        self.player?.seek(to: jump)
    }
    
    func play() {
        if self.player?.rate == 0 {
            self.player?.play()
        } else {
            self.player?.pause()
        }
    }
    
    func rewind() {
        let currentTime = self.player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) - Double(valor), preferredTimescale: currentTime!.timescale)
        self.player?.seek(to: jump)
    }
}
