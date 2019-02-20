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
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayerIsSetUp(_:)), name: .playerIsSetUp, object: nil)
        
//        let height = self.getSizesDelegate!.getMiniContainerFrameHight()
//        playerManager.shared.miniContainerFrameHight = height
    }
    @objc func onPlayerIsSetUp(_ notification: Notification) {
        setMiniPlayerBottomConstraint()
    }

    func setMiniPlayerBottomConstraint() {
        //to put the miniView right above the tabBar
        let tabBarHeight = self.tabBar.frame.height
        let safeAreBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        let justTheTabBar = tabBarHeight - safeAreBottom
        self.getSizesDelegate?.getMiniContainerBottonConstrain().constant -= justTheTabBar

        
    }
}
