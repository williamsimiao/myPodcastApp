//
//  CellWithProgress.swift
//  myPodcastApp
//
//  Created by William on 19/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import UICircularProgressRing

protocol CellWithProgressDelegate {
    func clickDownload(theResumo: Resumo)
    func clickFavorito(theResumo: Resumo)
}

class CellWithProgress: UITableViewCell, UICircularProgressRingDelegate {
    
    @IBOutlet weak var downloadProgress: UICircularProgressRing!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var favoritoBtn: UIButton!
    
    var resumo: Resumo?
    var delegate: CellWithProgressDelegate?
    var downloadBtnState: playButtonStates?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        downloadProgress.delegate = self
        downloadProgress.maxValue = 1
        downloadProgress.value = 0
        downloadProgress.innerRingWidth = 2
        downloadProgress.innerRingSpacing = 0
        downloadProgress.innerRingColor = ColorWeel().orangeColor
        downloadProgress.outerRingColor = .gray
        downloadProgress.outerRingWidth = 2
        downloadProgress.shouldShowValueText = false
        downloadProgress.isHidden = true
        
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
        if resumo?.favoritado == 0 {
            favoritoBtn.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
            favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        } else {
            favoritoBtn.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
            favoritoBtn.tintColor = UIColor.white
        }
        
        self.delegate?.clickFavorito(theResumo: self.resumo!)
    }
    
    func changeDownlodStateToPaused() {
        downloadBtn.setImage(UIImage(named: "miniPlay")!, for: .normal)
    }
    
    func changeDownlodStateToInProgress() {
        downloadBtn.setImage(UIImage(named: "miniPause")!, for: .normal)
    }
    
    func update(progress: Float) {
        downloadProgress.value = CGFloat(progress)
    }

    
    @IBAction func clickDownload(_ sender: Any) {
        self.delegate?.clickDownload(theResumo: self.resumo!)
    }
}
