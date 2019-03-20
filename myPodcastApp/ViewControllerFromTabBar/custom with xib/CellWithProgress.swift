//
//  CellWithProgress.swift
//  myPodcastApp
//
//  Created by William on 19/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol CellWithProgressDelegate {
    func presentAlertOptions(theResumo: Resumo)
}


class CellWithProgress: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var resumo: Resumo?
    var delegate: CellWithProgressDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        coverImg.layer.cornerRadius = 10
        coverImg.clipsToBounds = true
        coverImg.layer.borderWidth = 1
        coverImg.layer.borderColor = UIColor.white.cgColor
        coverImg.backgroundColor = .orange
    }
    
    func setHighlightColor() {
        self.titleLabel.textColor = .black
        self.authorLabel.textColor = .black
        self.coverImg.layer.borderColor = UIColor.black.cgColor
        
    }
    func goBackToOriginalColors() {
        self.titleLabel.textColor = .white
        self.authorLabel.textColor = .white
        self.coverImg.layer.borderColor = UIColor.white.cgColor
    }
    @IBAction func clickMore(_ sender: Any) {        self.delegate?.presentAlertOptions(theResumo: self.resumo!)
    }
}
