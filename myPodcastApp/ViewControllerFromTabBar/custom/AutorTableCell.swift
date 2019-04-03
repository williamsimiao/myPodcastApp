//
//  AutoreTableCell.swift
//  myPodcastApp
//
//  Created by William on 21/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class AutorTableCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var photoImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImg.image = UIImage(named: "sem_imagem")!
        photoImg.layer.cornerRadius = photoImg.frame.height/2
        photoImg.clipsToBounds = true
    }
    
    func setHighlightColor() {
        nameLabel.textColor = .black
        photoImg.layer.borderColor = UIColor.black.cgColor
    }
    
    func goBackToOriginalColors() {
        nameLabel.textColor = .white
        photoImg.layer.borderColor = UIColor.white.cgColor
    }

}
