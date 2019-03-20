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
import RealmSwift

protocol episodeDataSourceProtocol {
    //TODO colocar uma classe da model
    func episodeDataChangedTo(imageURL:String, title:String)
}

class playerManager {
    //TODO TODO TODO remove this
    var miniContainerFrameHight: CGFloat?
    
    var player : AVPlayer?
    var isSet = false
    let skip_time = 10
    let interfaceUpdateInterval = 0.5
    let positionCheckerInterval = 5.0
    var episodesQueue = [[String:AnyObject]]()
    var currentEpisode : Resumo?
    var currentEpisodeType: episodeType!
    var sliderTimeObserver: Any?
    var progressTimeObserver: Any?
    static let shared = playerManager()
    
    private init() {}
    
    func addPeriodicTimeObserverToUpdateSlider() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let timeInterval = CMTime(seconds: interfaceUpdateInterval, preferredTimescale: timeScale)
        self.player!.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            if self!.getIsPlaying() {
                let currentTime = self!.getEpisodeCurrentTimeInSeconds()
                
                NotificationCenter.default.post(name: .playerTimeDidProgress, object: self, userInfo: ["currentTime": currentTime])
            }
        }
    }
    
    func removePeriodicSliderTimeObserver() {
        if let token = self.sliderTimeObserver {
            self.player!.removeTimeObserver(token)
            self.sliderTimeObserver = nil
        }
    }
    
    func removePeriodicProgressTimeObserver() {
        if let token = self.progressTimeObserver {
            self.player!.removeTimeObserver(token)
            self.progressTimeObserver = nil
        }
    }
    
    func addTimeObserverToRecordProgress() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let timeInterval = CMTime(seconds: positionCheckerInterval, preferredTimescale: timeScale)
        self.player!.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            if self!.getIsPlaying() {
                self?.recordCurrentProgress()
            }
        }
    }
    
    //MARK - Getters
    
    func getEpisodeCodigo() -> String {
        return self.currentEpisode!.cod_resumo
    }
    
    func getEpisodeTitle() -> String {
        return self.currentEpisode!.titulo
    }
    
    func getEpisodeAuthor() -> String {
        
        let authorsList = self.currentEpisode!.autores
        let joinedNames =  Util.joinAuthorsNames(authorsList: authorsList)
        return joinedNames
    }
    
    func getEpisodeCoverImgUrl() -> String {
        return self.currentEpisode!.url_imagem
    }
    
    func getWantsToStartPlaying() -> Bool {
        guard let playerRate = self.player?.rate else {
            return false
        }
        return playerRate != 0
    }
    
    func getIsPlaying() -> Bool {
        guard let status = self.player?.timeControlStatus else {
            return false
        }
        if status == AVPlayer.TimeControlStatus.playing {
            return true
        }
        else {
            return false
        }
    }
    
    func getPlayerIsSet() -> Bool {
        return self.player == nil ? false : true
    }
    
    func getEpisodeDurationInSeconds() -> Double {
        guard let duration = self.player?.currentItem?.duration else {
            return 0
        }
        let durationSeconds = Double(CMTimeGetSeconds(duration))
        if durationSeconds.isNaN {
            return 0.0
        }
        else {
            return durationSeconds
        }
    }
    
    func getEpisodeCurrentTimeInSeconds() -> Double {
        guard let currentTime = self.player?.currentItem?.currentTime() else {
            return 0
        }
        return CMTimeGetSeconds(currentTime)
    }
    
    //MARK Mudando de Episodio
    func episodeSelected(episode: Resumo, episodeLink: URL, episodeType: episodeType) -> Bool {
        
        if !AppService.util.checkIfVisitanteIsAbleToPlay(resumo: episode) {
            return false
        }

        //TODO: the bad side of this design is the avitem is set even if the episode selected is the same as the current
        let newEpisodeAVItem = AVPlayerItem(url: episodeLink)
        
        if playerManager.shared.getPlayerIsSet() {
            removePeriodicSliderTimeObserver()
            removePeriodicProgressTimeObserver()

            let currentEpisodeId = self.currentEpisode!.cod_resumo
            let newEpisodeId = episode.cod_resumo
            
            if (currentEpisodeId != newEpisodeId) || (self.currentEpisodeType != episodeType) {
                self.player?.pause()
                self.player?.replaceCurrentItem(with: newEpisodeAVItem)
            }
        }
        else {
            self.player = AVPlayer(playerItem: newEpisodeAVItem)
            NotificationCenter.default.post(name: .playerIsSetUp, object: self, userInfo: nil)
        }
        addPeriodicTimeObserverToUpdateSlider()
        addTimeObserverToRecordProgress()
        self.currentEpisode = episode
        self.currentEpisodeType = episodeType
        changeUIForEpisode()
        goToCurrentProgress()
        playPause(shouldPlay: true)
        return true
    }
    
    func changeUIForEpisode() {
        //To change UI
        NotificationCenter.default.post(name: .episodeDidChange, object: self, userInfo: nil)
        
        //Seting ControlCenter UI
        let artworkProperty = MPMediaItemArtwork(boundsSize: CGSize(width: 40, height: 40)) { (cgsize) -> UIImage in
            return Network.getUIImageFor(imageUrl: self.currentEpisode!.url_imagem)
            //return AppService.util.get_image_resumo(cod_resumo: self.currentEpisodeDict["cod_resumo"] as! String)
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle : "DOIDO", MPMediaItemPropertyArtist : "ResumoCast", MPMediaItemPropertyArtwork : artworkProperty, MPNowPlayingInfoPropertyDefaultPlaybackRate : NSNumber(value: 1), MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds((player!.currentItem?.duration)!)]
    }
    
    //MARK - MODIFICADORES de tempo
    func foward() {
        jumpBy(seconds: Double(skip_time))
    }
    
    func changePlaybackRate(rate: Float) {
        var isPaused = false
        if player?.rate == 0 {
            isPaused = true
        }
        
        self.player?.rate = rate
        
        if isPaused {
            player?.pause()
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
        recordCurrentProgress()
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
    
    func stopPlayer() {
        removePeriodicProgressTimeObserver()
        removePeriodicSliderTimeObserver()
        recordCurrentProgress()
        
        self.player = nil
    }
    
    func recordCurrentProgress() {
        guard let _ = currentEpisode else {
            return
        }
        let resumoEntity = AppService.realm().objects(ResumoEntity.self).filter("cod_resumo = %@", currentEpisode?.cod_resumo).first
        let durationSeconds = playerManager.shared.getEpisodeDurationInSeconds()

        try! AppService.realm().write {
            if self.currentEpisodeType == episodeType.ten {
                resumoEntity?.progressPodcast_10 = self.getEpisodeCurrentTimeInSeconds()
            }
            else if self.currentEpisodeType == episodeType.fortyPremium {
                resumoEntity?.progressPodcast_40_p = self.getEpisodeCurrentTimeInSeconds()
                resumoEntity?.duration_40_p = durationSeconds

            }
            //FORTY FREE
            else {
                resumoEntity?.progressPodcast_40_f = self.getEpisodeCurrentTimeInSeconds()
                resumoEntity?.duration_40_f = durationSeconds
            }
        }
    }
    
    func goToCurrentProgress() {
        let currentResumo = AppService.realm().objects(ResumoEntity.self).filter("cod_resumo = %@", currentEpisode?.cod_resumo).first
        
        if self.currentEpisodeType == episodeType.ten {
            let currentProgress = currentResumo?.progressPodcast_10
            jumpTo(seconds: currentProgress!)
        }
        else if self.currentEpisodeType == episodeType.fortyPremium {
            let currentProgress = currentResumo?.progressPodcast_40_p
            jumpTo(seconds: currentProgress!)
        }
        //FORTY FREE
        else {
            let currentProgress = currentResumo?.progressPodcast_40_f
            jumpTo(seconds: currentProgress!)
        }
        

    }
    
//    //MARK - Queue management
//    func insert(episode:[String:AnyObject]) {
//        self.episodesQueue.append(episode)
//    }
//
//    func insertAtQueueBegening(episode:[String:AnyObject]) {
//        self.episodesQueue.insert(episode, at: 0)
//    }
//
//    func getNextInQueue() -> [String:AnyObject] {
//        return self.episodesQueue.removeFirst()
//    }
}
