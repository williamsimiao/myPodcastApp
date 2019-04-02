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
    func viewClicked()
    func favClicked()
    func downloadClicked(state: DownlodState)
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
    var downloadState: DownlodState?
    
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
//            downloadProgress.isHidden = false
            downloadBtn.setImage(UIImage(named: "stop"), for: .normal)
        }
        else {
            
//            downloadProgress.isHidden = true
            if isDownloaded {
                downloadBtn.setImage(UIImage(named: "downloadOrange"), for: .normal)
            }
            else {
                downloadBtn.setImage(UIImage(named: "downloadWhite"), for: .normal)
//                download?.progress = 0
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
        delegate?.favClicked()
    }
    
    @IBAction func clickDownload(_ sender: Any) {
        
        delegate?.downloadClicked(state: DownlodState.none)
    }
    
    
    @objc func testTap() {
        self.delegate?.viewClicked()
    }
    
    
}
