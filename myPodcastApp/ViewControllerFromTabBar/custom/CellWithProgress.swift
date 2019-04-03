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
    func clickDownload()
    func clickFavorito(cell: CellWithProgress, theResumo: Resumo)
    func confirmDownloadDeletion(cell: CellWithProgress, urlString: String)
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
    
//    func updateDisplay(progress: Float, totalSize : String) {
//        downloadProgress.value = CGFloat(progress)
//        downloadProgress.isHidden = false
//        let porCento = String(format: "%.1f%% of %@", progress * 100, totalSize)
//    }

    func updateDisplay(progress: Float) {
        downloadProgress.value = CGFloat(progress)
    }
    
    func changeDownloadButtonLook(isDownloading: Bool, isDownloaded: Bool) {
        
        if isDownloading {
            downloadProgress.isHidden = false
            //downloadProgress.value =
            downloadBtn.setImage(UIImage(named: "stop"), for: .normal)
            downloadBtn.tintColor = .white
        }
        else {
            
            downloadProgress.isHidden = true
            if isDownloaded {
                downloadBtn.setImage(UIImage(named: "downloadOrange"), for: .normal)
                downloadBtn.tintColor = UIColor.init(hex: 0xFF8633)

            }
            else {
                downloadBtn.setImage(UIImage(named: "downloadWhite"), for: .normal)
                downloadBtn.tintColor = .white
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
    
    func setFavoritoBtn(favoritado: Bool) {
        if favoritado {
            favoritoBtn.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
            favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        } else {
            favoritoBtn.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
            favoritoBtn.tintColor = UIColor.white
        }
    }
    
    @IBAction func clickFavorito(_ sender: Any) {
        AppService.util.changeMarkResumoFavoritoField(cod_resumo: self.download!.resumo.cod_resumo)
        self.delegate?.clickFavorito(cell: self, theResumo: self.download!.resumo)
    }

    @IBAction func clickDownload(_ sender: Any) {
        let episodeUrlString: String
        let userIsPremium = false
        let theResumo = self.download!.resumo
        
        
        if userIsPremium {
            episodeUrlString = theResumo.url_podcast_40_p
        }
        else {
            episodeUrlString = theResumo.url_podcast_40_f
        }
        
        var resumos = AppService.util.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", theResumo.cod_resumo)
        guard let resumoEntity = resumos.first else {
            return
        }
        
        //DELETE DOWNLOAD
        if resumoEntity.downloaded == 1 {
            delegate!.confirmDownloadDeletion(cell: self, urlString: episodeUrlString)
        }
        else {
            let resumoURL = URL(string: episodeUrlString)!
            
            //CANCEL DOWNLOAD
            if resumoEntity.downloading == 1 {
                AppService.downloadService.cancelDownload(theResumo, resumoUrl: resumoURL)
                
                //Mark downloading as 0 on Realm
                AppService.util.changeMarkResumoDownloading(cod_resumo: theResumo.cod_resumo)
            }
            
            //START DOWNLOAD
            else {
                if AppService.util.isConnectedToNetwork() == false {
                    AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
                    return
                }
                //Mark downloading as 1 on Realm
                AppService.util.changeMarkResumoDownloading(cod_resumo: theResumo.cod_resumo)

                AppService.downloadService.startDownload(theResumo, resumoUrl: resumoURL)
            }
        }
        
        //UPdating self.download?.resumo
        resumos = AppService.util.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", theResumo.cod_resumo)
        guard let finalResumoEntity = resumos.first else {
            return
        }
        self.download?.resumo = Resumo(resumoEntity: finalResumoEntity)
        
        delegate?.clickDownload()
    }
    
}
