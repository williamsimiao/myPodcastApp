//
//  playerManager.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

protocol playerUIDelegate {
    func coverChanged(imageURL:String)
    func playingStateChanged(isPlaying:Bool)
    func titleChanged(title:String)
}

class playerManager {
    var MediaPlayer = MPMusicPlayerController.systemMusicPlayer
    let intervalo_tempo = 5
    var episodeDict = [String:AnyObject]()
    var delegate:playerUIDelegate?
    private var playerIsSet = false
    static let shared = playerManager()
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    private init() {}
    
    //MARK - Getters
    func getPlayerIsSet() -> Bool{
        return self.playerIsSet
    }
    
    func getEpisodeTitle() -> String {
        if let episodeTitle = self.episodeDict["title"] {
            return episodeTitle as! String
        }
        return ""
    }
    
    func getEpisodeCoverImgUrl() -> String {
        if let episodeTitle = self.episodeDict["image_url"] {
            return episodeTitle as! String
        }
        return ""
    }

    func getIsPlaying() -> Bool {
        return playerManager.shared.MediaPlayer.playbackState.rawValue == MPMusicPlayerController.systemMusicPlayer.pla
    }
    
    //MARK Mudando de Episodio
    
    func player_setup(episodeId:String) {
        self.playerIsSet = true
        
        self.delegate!.coverChanged(imageURL: self.getEpisodeCoverImgUrl())
        self.delegate!.titleChanged(title: self.getEpisodeTitle())
        self.delegate!.playingStateChanged(isPlaying: getIsPlaying())
        
        
        
//        self.player = AVPlayer(playerItem: mPlayerItem)
//        let playerLayer=AVPlayerLayer(player: player!)
//        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
//        motherView.layer.addSublayer(playerLayer)
        
        self.player?.play()
    }
    
    func changePlayingEpisode(episodeId:String, mPlayerItem:AVPlayerItem) {
            self.player?.pause()
            self.player?.replaceCurrentItem(with: mPlayerItem)
            self.player?.play()
    }
    
    
    //MARK MODIFICADORES de tempo
    func foward() {
        if playerManager.shared.getIsPlaying() {
            let currentTime = player?.currentItem?.currentTime()
            let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(intervalo_tempo), preferredTimescale: currentTime!.timescale)
            self.player?.seek(to: jump)
        }
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
        if playerManager.shared.getIsPlaying() {
            let currentTime = self.player?.currentItem?.currentTime()
            let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) - Double(intervalo_tempo), preferredTimescale: currentTime!.timescale)
            self.player?.seek(to: jump)
        }
    }
}
