//
//  TabBarViewController.swift
//  myPodcastApp
//
//  Created by William on 29/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    // MARK: - Properties
    var miniContainerViewReference: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLayoutForMiniPlayer()
        
    }
    
    func updateLayoutForMiniPlayer() {
        //Changing the miniPlayer position to be right above the tabbar
//        miniContainerViewReference?.frame.origin.y += self.tabBar.frame.origin.y + self.tabBar.frame.size.height
        miniContainerViewReference?.frame.origin.y += CGFloat(200)
        
        miniContainerViewReference?.superview!.setNeedsLayout()
        miniContainerViewReference?.superview!.layoutIfNeeded()
        
        
        let miniViewHeight = miniContainerViewReference?.frame.size.height
        
        //Changing the tabBar orin and size to have the height of tabbar+miniContainer
        self.tabBar.frame.origin.y -= miniViewHeight!
        self.tabBar.frame.size.height += CGFloat(200)
        
        self.tabBar.setNeedsLayout()
        self.tabBar.layoutIfNeeded()
    }
}
