//
//  ViewController.swift
//  myPodcastApp
//
//  Created by William on 21/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    let valor = 5
    @IBOutlet weak var play_button: UIBarButtonItem!
    var playBtn = UIBarButtonItem()
    var pauseBtn = UIBarButtonItem()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let murl = URL(string: "https://s3.amazonaws.com/kargopolov/kukushka.mp3")
        player_setup(url: murl!)
        player?.play()
    }
    
    func player_setup(url:URL) {
        let playerItem:AVPlayerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer=AVPlayerLayer(player: player!)
        playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
        self.view.layer.addSublayer(playerLayer)
    }
    
    @IBAction func play_action(_ sender: Any) {
        
        if player?.rate != 0 {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    @IBAction func back_action(_ sender: Any) {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) - Double(valor), preferredTimescale: currentTime!.timescale)
        player?.seek(to: jump)
    }
    
    
    @IBAction func fowardAction(_ sender: Any) {
        let currentTime = player?.currentItem?.currentTime()
        let jump = CMTimeMakeWithSeconds(CMTimeGetSeconds(currentTime!) + Double(valor), preferredTimescale: currentTime!.timescale)
        player?.seek(to: jump)
    }
    
    @objc func playBtnAction(sender: UIBarButtonItem)
    {
        player!.play()
        play_button = pauseBtn
    }
    
    @objc func pauseBtnAction(sender: UIBarButtonItem)
    {
        player!.pause()
        play_button = playBtn
    }
    

}

