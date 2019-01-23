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
        return playerManager.shared.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing
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
            self.player?.play()
        }
    }
    
    func foward() {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(valor), preferredTimescale: currentTime!.timescale)
        self.player?.seek(to: jump)
    }
    
    func play() {
        if getIsPlaying() {
            self.player?.pause()
        }
        else {
            self.player?.play()
        }
    }
    
    func rewind() {
        let currentTime = self.player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) - Double(valor), preferredTimescale: currentTime!.timescale)
        self.player?.seek(to: jump)
    }
}
