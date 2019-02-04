//
//  TabBarViewController.swift
//  myPodcastApp
//
//  Created by William on 29/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol TabBarViewControllerDelegate: class {
    func getMiniContainerBottonConstrain() -> NSLayoutConstraint
    func getMiniContainerFrameHight() -> CGFloat
}

class TabBarViewController: UITabBarController {
    // MARK: - Properties
    weak var getSizesDelegate: TabBarViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLayoutForMiniPlayer()
    }
    
    func updateLayoutForMiniPlayer() {
        
        self.getSizesDelegate?.getMiniContainerBottonConstrain().constant -= self.tabBar.frame.size.height
        
        
        //Changing the tabBar orin and size to have the height of tabbar+miniContainer
        guard let miniViewHeight = self.getSizesDelegate?.getMiniContainerFrameHight() else {
            assertionFailure("No MiniContainerFrameHight")
            return
        }
        
        for viewController in self.viewControllers! {
            if let ouvirVC = viewController as? OuvirViewController {
                ouvirVC.miniContainerHeight = miniViewHeight
            }
            else {
                print("Erro OuvirViewController")
            }
        }
        self.view.layoutIfNeeded()

        
        
    }
}
