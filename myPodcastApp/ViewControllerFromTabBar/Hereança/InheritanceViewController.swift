//
//  InheritanceViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class InheritanceViewController: UIViewController {
    var decreaseHightBy: CGFloat = 70.0
    var resizableView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    open func setupSubView() {
        resizableView.backgroundColor = .red
        resizableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(resizableView)
        
        //adding contrains
        
        //left and right margins
        let leadingConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        
        let trailingConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        
        
        //top and bottom
        let topConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
//
//        let bottomConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: self.decreaseHightBy*(-1))
//
//
//
//        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
//            let topContrain = resizableView.topAnchor.constraint(equalTo: guide.topAnchor)
            
            let bottomContrain =  guide.bottomAnchor.constraint(equalTo: resizableView.bottomAnchor, constant: self.decreaseHightBy)
            
            NSLayoutConstraint.activate([bottomContrain])

        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                resizableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: resizableView.bottomAnchor, constant: standardSpacing)
                ])
        }
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint])

    }

}
