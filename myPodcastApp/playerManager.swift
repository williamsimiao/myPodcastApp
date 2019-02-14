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
    static let playerTimeDidProgress = Notification.Name("playerTimeDidProgress")
}

protocol episodeDataSourceProtocol {
    //TODO colocar uma classe da model
    func episodeDataChangedTo(imageURL:String, title:String)
}

class playerManager {
    var player : AVPlayer?
    var isSet = false
    var timeObserverToken: Any?
    let skip_time = 10
    let interfaceUpdateInterval = 0.5
    var episodesQueue = [[String:AnyObject]]()
    var currentEpisodeDict = [String:AnyObject]()
    static let shared = playerManager()
    
    private init() {
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let timeInterval = CMTime(seconds: interfaceUpdateInterval, preferredTimescale: timeScale)
        
        self.player!.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            if self!.getIsPlaying() {
                let currentTime = CMTimeGetSeconds((self!.player?.currentItem?.currentTime())!)

                NotificationCenter.default.post(name: .playerTimeDidProgress, object: self, userInfo: ["currentTime": currentTime])
            }
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.player!.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    //MARK - Getters
    
    func getEpisodeTitle() -> String {
        if let episodeTitle = self.currentEpisodeDict["titulo"] {
            return episodeTitle as! String
        }
        return ""
    }
    
    func getEpisodeAuthor() -> String {
        
        return "-"
    }
    
    func getEpisodeCoverImgUrl() -> String {
        if let episodeTitle = self.currentEpisodeDict["url_imagem"] {
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
    
    func getPlayerIsSet() -> Bool {
        return self.isSet
    }
    
    func getEpisodeDurationInSeconds() -> Double {
        guard let durationTime = self.player?.currentItem?.duration else {
            return 0
        }
        let duration = CMTimeGetSeconds(durationTime)
        return Double(duration)
    }
    
    func getEpisodeCurrentTimeInSeconds() -> Double {
//        CMTimeGetSeconds(((self.player?.currentTime())!)
        return CMTimeGetSeconds((self.player?.currentItem?.currentTime())!)
    }
    
    //MARK Mudando de Episodio
    func episodeSelected(episodeDictionary: [String:AnyObject]) {
        
        //Getting episode AVPlayerItem
        let newEpisodeAVItem : AVPlayerItem
        
        //TODO: the bad side of this design is the avitem is set even if the episode selected is the same as the current
        do {
            newEpisodeAVItem = try getAVItem(ForEpisode: episodeDictionary)
        } catch AppError.urlKeyError {
            print("Erro - key for url not found")
            return
        } catch AppError.urlError {
            print("Erro - not possible to convert the string to URL")
            return
        } catch {
            print("Unexpected error: \(error).")
            return
        }
        
        if playerManager.shared.getPlayerIsSet() {
            let currentEpisodeId = self.currentEpisodeDict["cod_resumo"] as! String
            let newEpisodeId = episodeDictionary["cod_resumo"] as! String

            if currentEpisodeId != newEpisodeId {
                self.player?.pause()
                self.player?.replaceCurrentItem(with: newEpisodeAVItem)
            }
        }
        else {
            self.isSet = true
            self.player = AVPlayer(playerItem: newEpisodeAVItem)
            addPeriodicTimeObserver()

        }
        self.currentEpisodeDict = episodeDictionary
        changeUIForEpisode()
        playPause(shouldPlay: true)

    }
    
    func getAVItem(ForEpisode episodeDictionary:[String:AnyObject]) throws -> AVPlayerItem{
        guard let episodeLink = episodeDictionary["url_podcast_40_f"] else {
            throw AppError.urlKeyError
        }
        guard let episodeURL = URL(string: episodeLink as! String) else {
            throw AppError.urlError
        }
        return AVPlayerItem(url: episodeURL)
    }
    
    func changeUIForEpisode() {
        //To change UI
        NotificationCenter.default.post(name: .episodeDidChange, object: self, userInfo: self.currentEpisodeDict)
        
        //Seting ControlCenter UI
        let artworkProperty = MPMediaItemArtwork(boundsSize: CGSize(width: 40, height: 40)) { (cgsize) -> UIImage in
            return Network.getUIImageFor(imageUrl: self.currentEpisodeDict["url_imagem"] as! String)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : self.getEpisodeTitle(), MPMediaItemPropertyArtist : "ResumoCast", MPMediaItemPropertyArtwork : artworkProperty, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.duration)!)]
    }
    
    //MARK - MODIFICADORES de tempo
    func foward() {
        jumpBy(seconds: Double(skip_time))
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
        jumpBy(seconds: Double(-skip_time))
    }
    
    func jumpTo(seconds : Double) {
        let currentTime = self.player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(seconds, preferredTimescale: (currentTime?.timescale)!)
        self.player?.seek(to: jump)
    }
    
    func jumpBy(seconds:Double) {
        let currentTime = self.player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(seconds), preferredTimescale: currentTime!.timescale)
        self.player?.seek(to: jump)
    }
    
    //MARK - Queue management
    func insert(episode:[String:AnyObject]) {
        self.episodesQueue.append(episode)
    }
    
    func insertAtQueueBegening(episode:[String:AnyObject]) {
        self.episodesQueue.insert(episode, at: 0)
    }
    
    func getNextInQueue() -> [String:AnyObject] {
         return self.episodesQueue.removeFirst()
    }
}
