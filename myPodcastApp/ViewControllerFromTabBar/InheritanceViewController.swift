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
    var superResizableView : UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func resizeForMiniView() {
        let mytabBarVC = self.tabBarController as! TabBarViewController
        mytabBarVC.setMiniPlayerBottomConstraint()
        //Make the view go up
//        self.superResizableView!.translatesAutoresizingMaskIntoConstraints = false
        self.superResizableView?.frame.size.height -= mytabBarVC.miniContainerFrameHight!
        self.superResizableView?.layoutIfNeeded()
    }
}

