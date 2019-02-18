//
//  BaseViewController.swift
//  myPodcastApp
//
//  Created by William on 31/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class BaseViewController: InheritanceViewController {
    // MARK: - Properties
    @IBOutlet weak var bigContainerView: UIView!
    @IBOutlet weak var miniContainerView: UIView!
    @IBOutlet weak var miniContainerBottonConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        let showId = "2885428"
        let episodesUrl = "https://api.spreaker.com/v2/shows/" + showId + "/episodes"
        
        //TODO: tirar isso daqui
        
        Alamofire.request(episodesUrl).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let episodesData = swiftyJsonVar["response"]["items"].arrayObject {
                    let arrEpisodes = episodesData as! [[String:AnyObject]]
                }
            }
        }        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let miniPlayer = segue.destination as? MiniPlayerViewController {
            miniPlayer.expandDelegate = self
        }
        if let tabBarController = segue.destination as? TabBarViewController {
            tabBarController.getSizesDelegate = self
            
        }
    }
}

extension BaseViewController : TabBarViewControllerDelegate {
    func getMiniContainerBottonConstrain() -> NSLayoutConstraint {
        return self.miniContainerBottonConstrain
    }
    
    func getMiniContainerFrameHight() -> CGFloat {
        return self.miniContainerView.frame.height
    }
}
