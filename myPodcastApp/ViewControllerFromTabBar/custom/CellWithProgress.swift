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
    func clickDownload(aDownload: Download)
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
    
//    var resumo: Resumo?
    var download: Download?
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
    
    func updateDisplay(progress: Float, totalSize : String) {
        downloadProgress.value = CGFloat(progress)
        let porCento = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
    func changeDownloadButtonLook(isDownloading: Bool, isDownloaded: Bool) {
        if isDownloading {
            downloadProgress.isHidden = false
            downloadBtn.setImage(UIImage(named: "stop"), for: .normal)
        }
        else {
            
            downloadProgress.isHidden = true
            if isDownloaded {
                downloadBtn.setImage(UIImage(named: "downloadOrange"), for: .normal)
            }
            else {
                downloadBtn.setImage(UIImage(named: "downloadWhite"), for: .normal)
                download?.progress = 0
                downloadProgress.value = 0
            }
        }
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
        if self.download!.resumo.favoritado == 0 {
            favoritoBtn.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
            favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        } else {
            favoritoBtn.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
            favoritoBtn.tintColor = UIColor.white
        }
        
        self.delegate?.clickFavorito(theResumo: self.download!.resumo)
    }

    @IBAction func clickDownload(_ sender: Any) {
        self.delegate?.clickDownload(aDownload: self.download!)
    }
}
