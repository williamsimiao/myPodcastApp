//
//  resumoCollectionViewCell.swift
//  myPodcastApp
//
//  Created by William on 13/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class resumoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        coverImg.image = UIImage(named: "cover_placeholder")!
        titleLabel.isHidden = true
        coverImg.layer.cornerRadius = 10
        coverImg.layer.borderWidth = 1
        coverImg.layer.borderColor = UIColor.white.cgColor
        coverImg.clipsToBounds = true
    }
}
