//
//  CustomCell.swift
//  myPodcastApp
//
//  Created by William on 13/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImg.layer.cornerRadius = 10
        coverImg.clipsToBounds = true
        coverImg.layer.borderWidth = 1
        coverImg.layer.borderColor = UIColor.black.cgColor
        coverImg.backgroundColor = .orange
        
        //
    }
    
}
