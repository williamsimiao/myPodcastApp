//
//  LoginTextField.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
    let radius = CGFloat(20)
    
    override func draw(_ rect: CGRect) {
        setUpTextField()
    }
    func setUpTextField() {
        self.backgroundColor = .white
        self.textColor = .black
        self.tintColor = .black
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
    
   
    //MARK - for padding the placeholder
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

}
