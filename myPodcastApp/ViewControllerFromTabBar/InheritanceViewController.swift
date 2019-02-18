//
//  InheritanceViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol expandDelegate: class {
    func expandEpisode(miniPLayer: MiniPlayerViewController)
}

class InheritanceViewController: UIViewController {
    var miniViewHeight: CGFloat = 70.0
    var resizableView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension InheritanceViewController : MiniPlayerDelegate {
    func expandEpisode(miniPLayer: MiniPlayerViewController) {
        guard let playerCardVC = storyboard?.instantiateViewController(
            withIdentifier: "PlayerCardViewController")
            as? PlayerCardViewController else {
                assertionFailure("No view controller ID PlayerCardViewController in storyboard")
                return
        }
        
        playerCardVC.backingImage = self.view.makeSnapshot()
        playerCardVC.sourceView = miniPLayer
        playerCardVC.currentPlayButtonState = miniPLayer.currentPlayButtonState
        
        //Epidosode Data
        
        //Chamar delegate para a tabviewController fazer a animacao de sumir a tab
        //        if let tabBar = tabBarController?.tabBar {
        //            playerCardVC.tabBarImage = tabBar.makeSnapshot()
        //        }
        present(playerCardVC, animated: false)
    }
}

