//
//  welcomeButtom.swift
//  myPodcastApp
//
//  Created by William on 21/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class welcomeButtom: UIButton {

    override var intrinsicContentSize: CGSize {
        let screenWidth = UIScreen.main.bounds.width
        
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        
        return desiredButtonSize
    }
}
