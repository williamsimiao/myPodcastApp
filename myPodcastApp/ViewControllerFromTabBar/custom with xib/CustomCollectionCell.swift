//
//  CustomCollectionViewCell.swift
//  myPodcastApp
//
//  Created by William on 11/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomCollectionCell: UICollectionViewCell {
    @IBOutlet weak var authorImg: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorImg.layer.cornerRadius = 40
        authorImg.clipsToBounds = true
    }
}
