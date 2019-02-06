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

extension Notification.Name {
    static let playingStateDidChange = Notification.Name("playingStateDidChange")
    static let episodeDidChange = Notification.Name("episodeDidChange")
}

protocol episodeDataSourceProtocol {
    //TODO colocar uma classe da model
    func episodeDataChangedTo(imageURL:String, title:String)
}

class playerManager {
    var player : AVPlayer?
    let intervalo_tempo = 5
    var currentEpisodeDict = [String:AnyObject]()
    var delegate:episodeDataSourceProtocol?
    static let shared = playerManager()
    let requiredAssetKeys = [
        "playable",
        "hasProtectedContent"
    ]
    
    private init() {}
    
    //MARK - Getters
    
    func getEpisodeTitle() -> String {
        if let episodeTitle = self.currentEpisodeDict["title"] {
            return episodeTitle as! String
        }
        return ""
    }
    
    func getEpisodeCoverImgUrl() -> String {
        if let episodeTitle = self.currentEpisodeDict["image_url"] {
            return episodeTitle as! String
        }
        return ""
    }
    
    func getWantsToStartPlaying() -> Bool {
        return self.player?.rate != 0
    }

    func getIsPlaying() -> Bool {
        let boleano = playerManager.shared.player?.timeControlStatus == AVPlayer.TimeControlStatus.playing
        return boleano
    }
    
    //MARK Mudando de Episodio
    
    func player_setup(episodeDictionary:[String:AnyObject]) {
        self.currentEpisodeDict = episodeDictionary
        
        let episodeIdNumber = self.currentEpisodeDict["episode_id"] as! NSNumber
        let avItem = AVPlayerItem(url: Util.getUrl(forPlayingEpisode: episodeIdNumber))
        self.player = AVPlayer(playerItem: avItem)
        
        //To change UI
        self.delegate!.episodeDataChangedTo(imageURL: self.getEpisodeCoverImgUrl(), title: self.getEpisodeTitle())
        
        let artworkProperty = MPMediaItemArtwork(boundsSize: CGSize(width: 40, height: 40)) { (cgsize) -> UIImage in
            return Network.getUIImageFor(imageUrl: self.currentEpisodeDict["image_url"] as! String)
        }
        let episodeTitle = self.currentEpisodeDict["title"] as! String

        //Seting ControlCenter UI
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : episodeTitle, MPMediaItemPropertyArtist : "ResumoCast", MPMediaItemPropertyArtwork : artworkProperty, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.asset.duration)!)]
    }
    
    func changePlayingEpisode(episodeDictionary:[String:AnyObject]) {
        let currentEpisodeId = (self.currentEpisodeDict["episode_id"] as! NSNumber)
        let newEpisodeId = (episodeDictionary["episode_id"] as! NSNumber)
        if currentEpisodeId != newEpisodeId {
            self.player?.pause()
            self.currentEpisodeDict = episodeDictionary
            
            let newEpisodeAVItem = AVPlayerItem(url: Util.getUrl(forPlayingEpisode: newEpisodeId))
            self.player?.replaceCurrentItem(with: newEpisodeAVItem)
            self.player?.play()
        }
    }
    
    
    //MARK MODIFICADORES de tempo
    func foward() {
        if self.getIsPlaying() {
            let currentTime = player?.currentItem?.currentTime()
            let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(intervalo_tempo), preferredTimescale: currentTime!.timescale)
            self.player?.seek(to: jump)
        }
    }
    
    func playPause(shouldPlay:Bool) {
        //Notifing that the state changed
        if shouldPlay {
            self.player?.play()
        }
        else {
            self.player?.pause()
        }
        NotificationCenter.default.post(name: .playingStateDidChange, object: self, userInfo: ["isPlaying": shouldPlay])

    }
    
    func rewind() {
        if self.getIsPlaying() {
            let currentTime = self.player?.currentItem?.currentTime()
            let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) - Double(intervalo_tempo), preferredTimescale: currentTime!.timescale)
            self.player?.seek(to: jump)
        }
    }
}
