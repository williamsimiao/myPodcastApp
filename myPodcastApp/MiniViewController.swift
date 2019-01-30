//
//  MiniViewController.swift
//  myPodcastApp
//
//  Created by William on 29/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class MiniViewController: UIViewController, playerUIDelegate {
    func coverChanged(imageURL: String) {
        Util.setMiniCoverImg(with: imageURL, theImage: self.coverImg)
    }
    
    func playingStateChanged(isPlaying: Bool) {
        if isPlaying {
            if let pauseImg = UIImage(named: "pauseBranco_36") {
                self.playButton.setImage(pauseImg, for: UIControl.State.normal)
            }
        }
        else {
            if let playImg = UIImage(named: "playBranco_36") {
                self.playButton.setImage(playImg, for: UIControl.State.normal)
            }
        }
    }
    
    func titleChanged(title: String) {
        self.title = title
    }
    

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerManager.shared.delegate = self

        // Do any additional setup after loading the view.
    }
    

    @IBAction func contentViewTapAction(_ sender: Any) {
        print("AQUI")
    }
    @IBAction func playAction(_ sender: Any) {
        playerManager.shared.play()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
