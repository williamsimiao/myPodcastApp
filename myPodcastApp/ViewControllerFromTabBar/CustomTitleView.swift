//
//  CustomTitleView.swift
//  myPodcastApp
//
//  Created by William on 14/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomTitleView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CustomTitleView", owner: self, options: nil)
        contentView.fixInView(self)
    }
}
