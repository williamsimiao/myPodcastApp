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
    private var playerIsSet = false
    static let shared = playerManager()
    
    private init() {}
    
    func getUrl(from episodeId:String) -> URL{
        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeId + "/play"
        print(urlString)
//        return URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")!
        return URL(string: urlString)!
    }
    
    func getPlayerIsSet() -> Bool{
        return self.playerIsSet
    }
    
    func player_setup(episodeId:String, motherView:UIView) {
        self.playerIsSet = true
        let audioUrl = getUrl(from: episodeId)
        let playerItem:AVPlayerItem = AVPlayerItem(url: audioUrl)
        player = AVPlayer(playerItem: playerItem)
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
        motherView.layer.addSublayer(playerLayer)
        self.player?.play()
    }
    
    func changePlayingEpisode(episodeId:String) {
        self.player?.pause()
        let audioUrl = getUrl(from: episodeId)
        let mPlayerItem = AVPlayerItem(url: audioUrl)
        self.player?.replaceCurrentItem(with: mPlayerItem)
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
