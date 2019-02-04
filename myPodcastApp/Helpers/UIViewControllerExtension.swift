//
//  UIViewControllerExtension.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

extension UIViewController {
    private static var resizableViewHeight = CGFloat()
    var miniContainerHeight: CGFloat {
        get {
            return UIViewController.resizableViewHeight
        }
        set(newValue) {
            UIViewController.resizableViewHeight = newValue
        }
    }
}
