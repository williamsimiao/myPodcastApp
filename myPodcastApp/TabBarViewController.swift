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
    var miniContainerFrameHight: CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setMiniPlayerBottomConstraint() {
        //to put the miniView right above the tabBar
        let tabBarHeight = self.tabBar.frame.height
        self.getSizesDelegate?.getMiniContainerBottonConstrain().constant -= tabBarHeight
        let height = self.getSizesDelegate!.getMiniContainerFrameHight()
        self.miniContainerFrameHight = height
    }
}
