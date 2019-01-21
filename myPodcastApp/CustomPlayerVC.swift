//
//  CustomPlayerVC.swift
//  myPodcastApp
//
//  Created by William on 21/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVKit
import Photos

class CustomPlayerVC: AVPlayerViewController {
    
    
    init(mUrl : URL) {
        super.init(nibName: nil, bundle: nil)
        let player = AVPlayer.init(url: mUrl)
        self.player = player
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
}
