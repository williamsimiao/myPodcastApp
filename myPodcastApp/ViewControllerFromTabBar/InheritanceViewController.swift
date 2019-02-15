//
//  InheritanceViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class InheritanceViewController: UIViewController {
    var miniViewHeight: CGFloat = 70.0
    var resizableView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open func setupSubView() {
        self.resizableView.translatesAutoresizingMaskIntoConstraints = false
//        self.resizableView.backgroundColor = .green
        self.view.addSubview(resizableView)

        //adding contrains

        //left and right margins
        let leadingConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)

        let trailingConstraint = NSLayoutConstraint(item: resizableView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)

        //top
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            
            let topConstraint =  guide.topAnchor.constraint(equalTo: resizableView.topAnchor, constant: 0)
            NSLayoutConstraint.activate([topConstraint])
        }
        //bottom
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide

            let bottomContraint =  guide.bottomAnchor.constraint(equalTo: resizableView.bottomAnchor, constant: self.miniViewHeight)
            NSLayoutConstraint.activate([bottomContraint])


        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                resizableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: resizableView.bottomAnchor, constant: standardSpacing)
                ])
        }
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint])

    }

}
