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
        
    }
}

extension TabBarViewController : ResizeViewDelegate {
    func updateLayoutForMiniPlayer(miniViewHeight: CGFloat) {
        //Changing the miniPlayer position to be right above the tabbar
        miniContainerViewReference?.frame.origin.y += tabBar.frame.size.height
        miniContainerViewReference?.layoutIfNeeded()
        
        //Changing the tabBar orin and size to have the height of tabbar+miniContainer
        tabBar.frame.origin.y -= miniViewHeight
        tabBar.frame.size.height += miniViewHeight
        self.view.layoutIfNeeded()
    }
}
