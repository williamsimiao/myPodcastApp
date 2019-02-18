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

