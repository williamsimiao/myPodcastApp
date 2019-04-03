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
    
    var miniPlayerController : MiniPlayerViewController?
    let downDelegate = downloadDelegate()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.downDelegate.setSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let height = self.miniContainerView.bounds.height
        print("height: \(height)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let miniPlayer = segue.destination as? MiniPlayerViewController {
            miniPlayer.expandDelegate = self
            self.miniPlayerController = miniPlayer
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

extension BaseViewController : MiniPlayerDelegate {
    func expandEpisode() {
        guard let playerCardVC = storyboard?.instantiateViewController(
            withIdentifier: "PlayerCardViewController")
            as? PlayerCardViewController else {
                assertionFailure("No view controller ID PlayerCardViewController in storyboard")
                return
        }
        guard let miniPlayer = self.miniPlayerController else {
            return
        }
        
        playerCardVC.backingImage = self.view.makeSnapshot()
        playerCardVC.sourceView = miniPlayer
        playerCardVC.currentPlayButtonState = miniPlayer.currentPlayButtonState
        
        //Epidosode Data
        
        
        
        //Chamar delegate para a tabviewController fazer a animacao de sumir a tab
        //        if let tabBar = tabBarController?.tabBar {
        //            playerCardVC.tabBarImage = tabBar.makeSnapshot()
        //        }
        present(playerCardVC, animated: false)
    }
}
