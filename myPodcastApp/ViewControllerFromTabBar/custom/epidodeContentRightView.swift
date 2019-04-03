//
//  epidodeContentRightView.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import UICircularProgressRing

protocol contentViewDelegate : class {
    func clickFavorito()
    func clickDownload()
    func confirmDownloadDeletion(urlString: String)
}

class epidodeContentRightView: UIView {
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var favoritoBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var downloadProgress: UICircularProgressRing!
    
    
    var delegate : contentViewDelegate?
    var download: Download?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commomInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commomInit()
    }
    
    func commomInit() {
        Bundle.main.loadNibNamed("epidodeContentRight", owner: self, options: nil)
        
        let touchTest = UITapGestureRecognizer(target: self, action: #selector(self.testTap))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(touchTest)

        contentView.frame  = self.bounds
//        coverImg.backgroundColor = .orange
        coverImg.layer.cornerRadius = 10
        coverImg.clipsToBounds = true
        coverImg.layer.borderWidth = 1
        coverImg.layer.borderColor = UIColor.white.cgColor
        contentView.fixInView(self)
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

    
    func updateDisplay(progress: Float, totalSize : String) {
        downloadProgress.value = CGFloat(progress)
        let porCento = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }

    
    func changeFavIcon(isFavoritado: Bool) {
        if isFavoritado {
            favoritoBtn.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
            favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        } else {
            favoritoBtn.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
            favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
        }
    }
    
    func changeDownaloadStateTo(newState: DownlodState) {
        switch newState {
        case .baixado:
            downloadBtn.setImage(UIImage(named: "downloadOrange")!, for: .normal)
            downloadBtn.tintColor = UIColor.init(hex: 0xFF8633)

        case .baixando:
            downloadBtn.setImage(UIImage(named: "stop")!, for: .normal)
            downloadBtn.tintColor = .white

        case .none:
            downloadBtn.setImage(UIImage(named: "downloadWhite")!, for: .normal)
            downloadBtn.tintColor = .white
        }
    }
    
    @IBAction func clickFavorito(_ sender: Any) {
        delegate?.clickFavorito()
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
            delegate!.confirmDownloadDeletion(urlString: episodeUrlString)
        }
        else {
            let resumoURL = URL(string: episodeUrlString)!
            
            //CANCEL DOWNLOAD
            if resumoEntity.downloading == 1 {
                AppService.downloadService.cancelDownload(theResumo, resumoUrl: resumoURL)
                
                //Mark downloading as 0 on Realm
                AppService.util.changeMarkResumoDownloading(cod_resumo: theResumo.cod_resumo, isDownloading: false)
            }
                
                //START DOWNLOAD
            else {
                if AppService.util.isConnectedToNetwork() == false {
                    AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
                    return
                }
                //Mark downloading as 1 on Realm
                AppService.util.changeMarkResumoDownloading(cod_resumo: theResumo.cod_resumo, isDownloading: true)
                
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
    
    
    @objc func testTap() {
//        self.delegate?.viewClicked()
    }
    
    
}
