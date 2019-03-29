//
//  CustomUISlider.swift
//  myPodcastApp
//
//  Created by William on 20/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomUISlider: UISlider {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width + 5, height: bounds.size.height + 5))
        super.thumbRect(forBounds: customBounds, trackRect: rect, value: value)
        return customBounds
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        
        //keeps original origin and width, changes height, you get the idea
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 3.0))
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    //while we are here, why not change the image here as well? (bonus material)
    override func awakeFromNib() {
        //TODO: change this images
        self.setThumbImage(UIImage(named: "thumbDefault"), for: UIControl.State.normal)
//        self.setThumbImage(UIImage(named: "thumbSelected"), for: UIControl.State.highlighted)
        super.awakeFromNib()
    }
    
}
