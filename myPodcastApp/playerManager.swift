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
        return playerManager.shared.MediaPlayer.playbackState == .playing
    }
    
    //MARK Mudando de Episodio
    
    func player_setup(episodeId:String) {
        self.playerIsSet = true
        
        self.delegate!.coverChanged(imageURL: self.getEpisodeCoverImgUrl())
        self.delegate!.titleChanged(title: self.getEpisodeTitle())
        self.delegate!.playingStateChanged(isPlaying: getIsPlaying())
        self.MediaPlayer.play()
    }
    
    func changePlayingEpisode(episodeId:String, mPlayerItem:AVPlayerItem) {
        self.MediaPlayer.pause()
        //Mudar mediaItem
        self.MediaPlayer.play()
    }
    
    
    //MARK MODIFICADORES de tempo
    func foward() {
        if playerManager.shared.getIsPlaying() {
            self.MediaPlayer.currentPlaybackTime = self.MediaPlayer.currentPlaybackTime + Double(self.intervalo_tempo)
        }
    }
    
    func play() {
        if getIsPlaying() {
            self.MediaPlayer.pause()
        }
        else {
            self.MediaPlayer.play()
        }
    }
    
    func rewind() {
        if playerManager.shared.getIsPlaying() {
            self.MediaPlayer.currentPlaybackTime = self.MediaPlayer.currentPlaybackTime - Double(self.intervalo_tempo)
        }
    }
}
