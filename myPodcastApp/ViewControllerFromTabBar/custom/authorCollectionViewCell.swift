//
//  CustomCollectionViewCell.swift
//  myPodcastApp
//
//  Created by William on 11/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class authorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var authorImg: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var vejaMaisLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        authorImg.image = UIImage(named: "sem_imagem")!
        authorImg.layer.cornerRadius = 40
        authorImg.clipsToBounds = true
        vejaMaisLabel.text = "Veja mais"
    }
}
