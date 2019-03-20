//
//  epidodeContentRightView.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol contentViewDelegate : class {
    func viewClicked()
}

class epidodeContentRightView: UIView {
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet var contentView: UIView!
    var delegate : contentViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commomInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commomInit()
    }
    
    func commomInit() {
        Bundle.main.loadNibNamed("epidodeContentRight", owner: self, options: nil)
        
        let touchTest = UITapGestureRecognizer(target: self, action: #selector(self.testTap))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(touchTest)

        contentView.frame  = self.bounds
//        coverImg.backgroundColor = .orange
        coverImg.layer.cornerRadius = 10
        coverImg.clipsToBounds = true
        coverImg.layer.borderWidth = 1
        coverImg.layer.borderColor = UIColor.white.cgColor
        contentView.fixInView(self)
    }
    
    @objc func testTap() {
        self.delegate?.viewClicked()
    }
    
    
}
