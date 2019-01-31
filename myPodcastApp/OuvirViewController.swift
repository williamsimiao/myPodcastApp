//
//  OuvirViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON

class OuvirViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        let showId = "1530166"
        let episodesUrl = "https://api.spreaker.com/v2/shows/" + showId + "/episodes"
        Alamofire.request(episodesUrl).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let episodesData = swiftyJsonVar["response"]["items"].arrayObject {
                    let arrEpisodes = episodesData as! [[String:AnyObject]]
                    playerManager.shared.player_setup(episodeDictionary: arrEpisodes.first!)
                }
            }
        }
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
