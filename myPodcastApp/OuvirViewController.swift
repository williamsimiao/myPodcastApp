//
//  OuvirViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class OuvirViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let id_episode = "16631830"
        playerManager.shared.player_setup(episodeId: id_episode)
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
