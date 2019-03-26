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

extension Notification.Name {
    static let playingStateDidChange = Notification.Name("playingStateDidChange")
    static let episodeDidChange = Notification.Name("episodeDidChange")
    static let playerTimeDidProgress = Notification.Name("playerTimeDidProgress")
    static let fullPlayerShouldAppear = Notification.Name("fullPlayerShouldAppear")
    static let playerIsSetUp = Notification.Name("playerIsSetUp")
    static let playerShouldClose = Notification.Name("playerShouldClose")
}

protocol episodeDataSourceProtocol {
    //TODO colocar uma classe da model
    func episodeDataChangedTo(imageURL:String, title:String)
}

class playerManager: NSObject {
    //TODO TODO TODO remove this
    var miniContainerFrameHight: CGFloat?
    
    var player : AVPlayer?
    var autoPlayEnabled = true
    var isSet = false
    let skip_time = 10
    let prepareNextResumoLimit = 15
    let playbackEndingLimit = 0.0
    let interfaceUpdateInterval = 0.5
    let positionCheckerInterval = 1.0
    var episodesQueue = [[String:AnyObject]]()
    var currentEpisode : Resumo?
    var currentEpisodeType: episodeType!
    var sliderTimeObserver: Any?
    var progressTimeObserver: Any?
    var observer: NSKeyValueObservation?
    var nextAvitem: AVPlayerItem?
    var nextResumo:Resumo?

    static let shared = playerManager()
    
    private override init() {}
    
    func addPeriodicTimeObserverToUpdateSlider() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let timeInterval = CMTime(seconds: interfaceUpdateInterval, preferredTimescale: timeScale)
        self.player!.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] time in
            if self!.getIsPlaying() {
                let currentTime = self!.getEpisodeCurrentTimeInSeconds()
                let duration = self!.getEpisodeDurationInSeconds()

                NotificationCenter.default.post(name: .playerTimeDidProgress, object: self, userInfo: ["currentTime": currentTime, "duration": duration])
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
    
    func prepareAvItem(episodeLink: URL) -> AVPlayerItem {
        return AVPlayerItem(url: episodeLink)
    }
    
    //MARK Mudando de Episodio
    func episodeSelected(episode: Resumo, episodeLink: URL?, episodeType: episodeType, preLoadedAVItem: AVPlayerItem?) throws -> Bool {
        var newEpisodeAVItem: AVPlayerItem
        guard preLoadedAVItem != nil || episodeLink != nil  else {
            throw AppError.urlError
        }
        
        if preLoadedAVItem == nil {
            newEpisodeAVItem = prepareAvItem(episodeLink: episodeLink!)

        }
        else {
            newEpisodeAVItem = preLoadedAVItem!
        }
        
        if !AppService.util.checkIfVisitanteIsAbleToPlay(resumo: episode) {
            return false
        }
        if playerManager.shared.getPlayerIsSet() {
            removePeriodicSliderTimeObserver()
            removePeriodicProgressTimeObserver()

            let currentEpisodeId = self.currentEpisode!.cod_resumo
            let newEpisodeId = episode.cod_resumo
            
            if (currentEpisodeId != newEpisodeId) || (self.currentEpisodeType != episodeType) {
                self.player?.pause()
//                self.player?.currentItem?.removeObserver(self, forKeyPath: "status")
                self.player?.replaceCurrentItem(with: newEpisodeAVItem)
            }
        }
        else {
            self.player = AVPlayer(playerItem: newEpisodeAVItem)
            NotificationCenter.default.post(name: .playerIsSetUp, object: self, userInfo: nil)
        }
        
        self.player!.currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        addPeriodicTimeObserverToUpdateSlider()
        addTimeObserverToRecordProgress()
        self.currentEpisode = episode
        self.currentEpisodeType = episodeType
        changeUIForEpisode()
        playPause(shouldPlay: true)
        goToCurrentProgress()
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.player!.currentItem?.status == AVPlayerItem.Status.readyToPlay {
            NotificationCenter.default.post(name: .fullPlayerShouldAppear, object: self, userInfo: nil)
        }

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
        
        self.player = nil
    }
    
    func recordCurrentProgress() {
        guard let _ = currentEpisode else {
            return
        }
        let resumoEntity = AppService.util.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", currentEpisode?.cod_resumo).first
        let durationSeconds = playerManager.shared.getEpisodeDurationInSeconds()
        let progressInseconds = self.getEpisodeCurrentTimeInSeconds()

        try! AppService.realm().write {
            if self.currentEpisodeType == episodeType.ten {
                resumoEntity?.progressPodcast_10 = progressInseconds
                resumoEntity?.durationPodcast_10 = durationSeconds
            }
            else if self.currentEpisodeType == episodeType.fortyPremium {
                resumoEntity?.progressPodcast_40_p = progressInseconds
                resumoEntity?.duration_40_p = durationSeconds

            }
            //FORTY FREE
            else {
                resumoEntity?.progressPodcast_40_f = progressInseconds
                resumoEntity?.duration_40_f = durationSeconds
            }
        }
        
        let remainingSeconds = durationSeconds - progressInseconds
        
        if Int(remainingSeconds) == prepareNextResumoLimit && durationSeconds > 0 {
            print("Ta acabando")
            
            //prepare for next resumo
            if autoPlayEnabled {
                playNext()
            }
        }
        
        if remainingSeconds <= playbackEndingLimit {
            playPause(shouldPlay: false)
            print("Acabou")
            
            try! AppService.realm().write {
                if self.currentEpisodeType == episodeType.ten {
                    resumoEntity?.concluido_podcast_10 = 1
                }
                    //FORTY FREE or PREMIUM
                else {
                    resumoEntity?.concluido_podcast_40 = 1
                }
            }
            var shouldClosePlayer = false
            if autoPlayEnabled {
                if let _ = self.nextAvitem {
                    do {
                        let userIsAllowedToPlay = try self.episodeSelected(episode: self.nextResumo!, episodeLink: nil, episodeType: self.currentEpisodeType , preLoadedAVItem: self.nextAvitem)
                        
                        if userIsAllowedToPlay == false {
                            AppService.util.handleNotAllowed()
                        }
                        self.nextAvitem = nil
                        self.nextResumo = nil
                    } catch AppError.urlError {
                        print("URL ERROR")
                    } catch {
                        print("episodeSelected ERROR unknown")
                    }
                }
                //Resumo is over and there is no up next
                else {
                    shouldClosePlayer = true
                }
            }
            else {
                shouldClosePlayer = true
            }
            if shouldClosePlayer {
                NotificationCenter.default.post(name: .playerShouldClose, object: self, userInfo: nil)
            }
        }
    }
    
    func goToCurrentProgress() {
        var currentProgress: Double
        var duration: Double
        let currentResumo = AppService.realm().objects(ResumoEntity.self).filter("cod_resumo = %@", currentEpisode?.cod_resumo).first

        if self.currentEpisodeType == episodeType.ten {
            currentProgress = (currentResumo?.progressPodcast_10)!
            duration = (currentResumo?.durationPodcast_10)!
        }
        else if self.currentEpisodeType == episodeType.fortyPremium {
            currentProgress = (currentResumo?.progressPodcast_40_p)!
            duration = (currentResumo?.duration_40_p)!
        }
        //FORTY FREE
        else {
            currentProgress = (currentResumo?.progressPodcast_40_f)!
            duration = (currentResumo?.duration_40_f)!
        }
        //if was concluided the start fro the begining
        let remainingSeconds = duration - currentProgress
        if remainingSeconds <= 0.0 {
            currentProgress = 0.0
        }
        print("progress:\(currentProgress)")
        jumpTo(seconds: currentProgress)
    }
    
    func playNext() {
        do {
            let nextResumo = try getNextResumo(currentResumo: self.currentEpisode!)
//            let theType: episodeType
            let avItem: AVPlayerItem
            let url: URL?
            if self.currentEpisodeType == episodeType.fortyFree {
                url = URL(string: nextResumo.url_podcast_40_f)
            }
            else if self.currentEpisodeType == episodeType.fortyPremium {
                url = URL(string: nextResumo.url_podcast_40_p)
            }
            else  {
                url = URL(string: nextResumo.url_podcast_10)
            }
            avItem = prepareAvItem(episodeLink: url!)
            self.nextAvitem = avItem
            self.nextResumo = nextResumo
            
        } catch AppError.noRealmResult {
            print("ERROR noRealmResult")
        } catch {
            print("unknown ERROR")
        }
    }
    
    func getNextResumo(currentResumo: Resumo) throws -> Resumo {
        
        //get the Resumos posted after the currently playing, from the oldest to the latest
        let nextResumo = AppService.util.realm.objects(ResumoEntity.self).filter("pubDate > %@", currentResumo.pubDate!).sorted(byKeyPath: "pubDate", ascending: true).first
        guard nextResumo != nil else {
            throw AppError.noRealmResult
        }
        let resumo = Resumo(resumoEntity: nextResumo!)
        return resumo
    }
    
    func getPreviusResumo(currentResumo: Resumo) throws -> Resumo {
        //get the Resumos posted before the currently playing, from the latest to the oldest
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: currentResumo.pubDate!)

        let previusResumo = AppService.util.realm.objects(ResumoEntity.self).filter("pubDate < \(dateString) ").sorted(byKeyPath: "pubDate", ascending: false).first
        guard previusResumo != nil else {
            throw AppError.noRealmResult
        }
        print("cod: \(String(describing: previusResumo?.cod_resumo)) nome: \(String(describing: previusResumo?.titulo))")
        let resumo = Resumo(resumoEntity: previusResumo!)
        return resumo
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
