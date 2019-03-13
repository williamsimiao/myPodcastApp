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
        coverImg.layer.cornerRadius = 10
        coverImg.clipsToBounds = true
    }
}
