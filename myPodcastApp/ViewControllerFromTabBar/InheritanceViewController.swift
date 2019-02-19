//
//  InheritanceViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class InheritanceViewController: UIViewController {
    var superResizableView : UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onPlayerIsSetUp(_:)), name: .playerIsSetUp, object: nil)
    }
    
    @objc func onPlayerIsSetUp(_ notification: Notification) {
        resizeForMiniView()
    }

    func resizeForMiniView() {
        
        //Make the view go up
        guard let resizableView = self.superResizableView else {
            return
        }
//        resizableView.translatesAutoresizingMaskIntoConstraints = false
//        resizableView.frame.size.height -= playerManager.shared.miniContainerFrameHight!
//        resizableView.layoutIfNeeded()
    }
}

