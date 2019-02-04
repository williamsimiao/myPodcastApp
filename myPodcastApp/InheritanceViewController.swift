//
//  InheritanceViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class InheritanceViewController: UIViewController {
    var miniContainerHeight: CGFloat = 70.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //creating resizable View
        let windowRect = view.convert(view.frame, to: nil)
        let resizableView = UIView()
        resizableView.translatesAutoresizingMaskIntoConstraints = false
        resizableView.backgroundColor = .black
        self.view.addSubview(resizableView)

        //adding contrains

        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            resizableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            resizableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
            ])
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                resizableView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: resizableView.bottomAnchor, multiplier: 1.0)
                ])
            
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                resizableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: resizableView.bottomAnchor, constant: standardSpacing)
                ])
        }
        
    }

//    func updateContrain() {
//        constrain.constant += self.miniContainerHeight
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
