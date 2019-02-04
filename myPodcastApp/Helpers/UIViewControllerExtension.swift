//
//  UIViewControllerExtension.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
protocol viewControllersResizeProtocol {
    func updateContrain(constrain : NSLayoutConstraint)
}
extension UIViewController : viewControllersResizeProtocol {
    func updateContrain(constrain: NSLayoutConstraint) {
        constrain.constant += self.miniContainerHeight
    }
    
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
