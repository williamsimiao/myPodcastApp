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
    func playingStateChanged(toPause:Bool)
    func titleChanged(title:String)
}

class playerManager {
    var player : AVPlayer?
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
        let boleano = playerManager.shared.player?.rate == 0
        print(boleano)
        return boleano
    }
    
    //MARK Mudando de Episodio
    
    func player_setup(episodeDictionary:[String:AnyObject]) {
        self.playerIsSet = true
        self.episodeDict = episodeDictionary
        
        self.delegate!.coverChanged(imageURL: self.getEpisodeCoverImgUrl())
        self.delegate!.titleChanged(title: self.getEpisodeTitle())
        //Se está tocando então eh verdade que o estado mudou para Pause
        self.delegate!.playingStateChanged(toPause: getIsPlaying())
        
        self.episodeDict = episodeDictionary
        
        let episodeIdNumber = self.episodeDict["episode_id"] as? NSNumber
        let episodeId = episodeIdNumber!.stringValue
        let episodeTitle = self.episodeDict["title"] as! String
//        let episodeDuration = self.episodeDict["duration"]
        
        
        let episodeUrl = Util.getUrl(from: episodeId)
        let avItem = AVPlayerItem(url: episodeUrl)
        self.player = AVPlayer(playerItem: avItem)
        
        self.player!.play()
        
        let artworkProperty = MPMediaItemArtwork(boundsSize: CGSize(width: 40, height: 40)) { (cgsize) -> UIImage in
            return Network.getUIImageFor(imageUrl: self.episodeDict["image_url"] as! String)
        }
        //k(image: song.artwork)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : episodeTitle, MPMediaItemPropertyArtist : "ResumoCast", MPMediaItemPropertyArtwork : artworkProperty, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!)]

        
        self.MediaPlayer.play()
    }
    
    func changePlayingEpisode(episodeId:String, mPlayerItem:AVPlayerItem) {
        //Mudar mediaItem
        self.MediaPlayer.play()
    }
    
    
    //MARK MODIFICADORES de tempo
    func foward() {
        if playerManager.shared.getIsPlaying() {
            self.player?.currentTime() = self.player?.currentTime() + intervalo_tempo
        }
    }
    
    func play() {
        self.delegate!.playingStateChanged(toPause: getIsPlaying())

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
