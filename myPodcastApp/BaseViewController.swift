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

class BaseViewController: UIViewController {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let miniPlayer = segue.destination as? MiniPlayerViewController {
            miniPlayer.expandDelegate = self
        }
        if let tabBarController = segue.destination as? TabBarViewController {
            tabBarController.getSizesDelegate = self
        }
    }
}

extension BaseViewController : MiniPlayerDelegate {
    func expandEpisode(miniPLayer: MiniPlayerViewController) {
        guard let playerCardVC = storyboard?.instantiateViewController(
            withIdentifier: "PlayerCardViewController")
            as? PlayerCardViewController else {
                assertionFailure("No view controller ID PlayerCardViewController in storyboard")
                return
        }
        
        playerCardVC.backingImage = self.bigContainerView.makeSnapshot()
        playerCardVC.sourceView = miniPLayer
        
        //Epidosode Data
        
        
        //Chamar delegate para a tabviewController fazer a animacao de sumir a tab
//        if let tabBar = tabBarController?.tabBar {
//            playerCardVC.tabBarImage = tabBar.makeSnapshot()
//        }
        present(playerCardVC, animated: false)
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
