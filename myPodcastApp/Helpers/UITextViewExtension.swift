//
//  UITextViewExtension.swift
//  myPodcastApp
//
//  Created by William on 25/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

extension UITextView {

    func makeOutLine(oulineColor: UIColor, foregroundColor: UIColor) {
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : oulineColor,
            NSAttributedString.Key.foregroundColor : foregroundColor,
            NSAttributedString.Key.strokeWidth : -4.0,
            NSAttributedString.Key.font : self.font as Any,
            ] as [NSAttributedString.Key : Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
    }
    
    func changeFontSize(newSize : Float) {
        self.font =  UIFont(name: (self.font?.fontName)!, size: CGFloat(newSize))
    }


}
