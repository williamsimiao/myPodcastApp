//
//  UIBarButtonItemExtension.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

public extension UIBarButtonItem {
    
    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        return menuBarItem
    }
    
    @IBInspectable var accEnabled: Bool {
        get {
            return isAccessibilityElement
        }
        set {
            isAccessibilityElement = newValue
        }
    }
    
    @IBInspectable var accLabelText: String? {
        get {
            return accessibilityLabel
        }
        set {
            accessibilityLabel = newValue
        }
    }
    
    var isHidden: Bool {
        get {
            return tintColor == UIColor.clear
        }
        set(hide) {
            if hide {
                isEnabled = false
                tintColor = UIColor.clear
            } else {
                isEnabled = true
                tintColor = ColorWeel().orangeColor // This sets the tinColor back to the default. If you have a custom color, use that instead
            }
        }
    }
}
