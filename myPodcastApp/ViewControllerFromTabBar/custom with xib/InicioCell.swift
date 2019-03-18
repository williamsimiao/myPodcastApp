//
//  CustomCell.swift
//  myPodcastApp
//
//  Created by William on 13/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

protocol inicioCellDelegate {
    func changeFavoritoState(cod_resumo: String)
}

class InicioCell: UITableViewCell {
    
    @IBOutlet weak var favoritoMark: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var favoritoButton: UIButton!
    
    var delegate: inicioCellDelegate?
    var cod_resumo: String?
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
    
    @IBAction func clickFavorito(_ sender: Any) {
        let resumo = AppService.util.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.cod_resumo).first

        if resumo?.favoritado == 0 {
            favoritoButton.imageView?.image = UIImage(named: "favoritoOrange")!
            favoritoButton.tintColor = UIColor.init(hex: 0xFF8633)
        } else {
            favoritoButton.imageView?.image = UIImage(named: "favoritoWhite")!
            favoritoButton.tintColor = UIColor.white
        }
        delegate?.changeFavoritoState(cod_resumo: self.cod_resumo!)
    }
    
    
}
