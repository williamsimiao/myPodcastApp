//
//  DetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Toast_Swift

enum linkType: String {
    case fortyFree = "url_podcast_40_f"
    case fortyPremium = "url_podcast_40_p"
    case ten = "url_podcast_10"
}


class DetalheViewController: InheritanceViewController {
    
    @IBOutlet weak var episodeContentView: epidodeContentRightView!
    @IBOutlet weak var FortyMinutesView: UIView!
    @IBOutlet weak var fortyMinutesButton: UIButton!
    @IBOutlet weak var fortyLoading: UIActivityIndicatorView!
    
    @IBOutlet weak var TenMinutesView: UIView!
    @IBOutlet weak var tenMinutesButton: UIButton!
    @IBOutlet weak var tenLoading: UIActivityIndicatorView!
    
    
    @IBOutlet weak var resizableView: UIView!
    
    @IBOutlet weak var resizableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var resumoView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var btnDownload: UIBarButtonItem!
    
    @IBOutlet weak var btnSalvar: UIBarButtonItem!
    
    var realm = AppService.realm()
    
    
    var selectedResumo : Resumo?
    var selectedResumoImage : UIImage?
    var success: Bool?
    var detailsEpisode: [String: AnyObject]?
    var error_msg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.superResizableView = resizableView
        self.superBottomConstraint = resizableBottomConstraint
        
        episodeContentView.delegate = self
        setupUI()
        
        // verificar se eh favorito
        let cod_resumo = selectedResumo?.cod_resumo
        
        let resumos = self.realm.objects(ResumoEntity.self)
            .filter("cod_resumo = %@", cod_resumo!);
        
        if let resumo = resumos.first {
                
            if resumo.favoritado == 1 {
                btnSalvar.image = UIImage(named: "favoritoOrange")!
                btnSalvar.tintColor = UIColor.init(hex: 0xFF8633)
            } else {
                btnSalvar.image = UIImage(named: "favoritoWhite")!
                btnSalvar.tintColor = UIColor.white
            }
            
        }
        
        // resumo texto 10
        let resumo = selectedResumo?.resumo_10
        
        textView.text = resumo
        
        if resumo == "" {
            resumoView.isHidden = true
        }
        else {
            resumoView.isHidden = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fortyLoading.stopAnimating()
        self.fortyLoading.isHidden = true
        
        self.tenLoading.stopAnimating()
        self.tenLoading.isHidden = true
    }
    
    func createURLWithComponents(cod_resumo: String) -> URL? {
        
        // create "https://api.nasa.gov/planetary/apod" URL using NSURLComponents
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.resumocast.com.br/ws"
        urlComponents.path = "/detalheResumo.php"
        
        // add params
        let cod_resumo = NSURLQueryItem(name: "cod_resumo", value: cod_resumo)
        urlComponents.queryItems = [cod_resumo] as [URLQueryItem]
        
        return urlComponents.url
    }
    
    func checkAvaliableLinks() {
        if selectedResumo?.url_podcast_40_f == nil || selectedResumo?.url_podcast_40_f == "" {
            fortyMinutesButton.isEnabled = false
        }
        
        if selectedResumo?.url_podcast_10 == nil || selectedResumo?.url_podcast_10 == "" {
            tenMinutesButton.isEnabled = false
        }
    }
    
    @IBAction func clickPlayButton(_ sender: Any) {
        let episodeLink : URL
        
        let resumo = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.selectedResumo?.cod_resumo as Any).first
        let senderObject = sender as AnyObject
        
        if senderObject.isEqual(self.tenMinutesButton) &&  resumo?.downloaded == 1 {
            episodeLink = getLocalURL(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_10)!)!)
        }
        else if senderObject.isEqual(self.tenMinutesButton) &&  resumo?.downloaded == 0 {
            episodeLink = URL(string: (self.selectedResumo?.url_podcast_10)!)!
            self.tenLoading.isHidden = false
            self.tenLoading.startAnimating()
        }
        else if senderObject.isEqual(self.fortyMinutesButton) &&  resumo?.downloaded == 1 {
            episodeLink = getLocalURL(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_40_f)!)!)
        }
        else {
            episodeLink = URL(string: (self.selectedResumo?.url_podcast_40_f)!)!
            self.fortyLoading.isHidden = false
            self.fortyLoading.startAnimating()
        }

        let userIsAllowedToPlay = playerManager.shared.episodeSelected(episode: selectedResumo!, episodeLink: episodeLink)
        
        if userIsAllowedToPlay {            
            NotificationCenter.default.post(name: .fullPlayerShouldAppear, object: self, userInfo: nil)
        }
        else {
            AppService.util.handleNotAllowed()
        }
    }
    
    func getLocalURL(sender: Any, serverUrl: URL) -> URL {
        var episodeLink  = serverUrl
        do {
            
            try episodeLink = AppService.util.getPathFromDownloadedAudio(urlString: (selectedResumo?.url_podcast_40_f)!)
            
        } catch AppError.filePathError {
            print("filePathError error")
            
        } catch {
            print("Unexpected error: \(error).")
        }
        return episodeLink
    }
    
    func setupUI() {
        let titulo =  self.selectedResumo?.titulo
        self.episodeContentView.titleLabel.text = titulo
        let authorsList = self.selectedResumo?.autores
        let joinedNames = Util.joinAuthorsNames(authorsList: authorsList!)
        self.episodeContentView.authorLabel.text = joinedNames
        self.episodeContentView.coverImg.image = self.selectedResumoImage
        
        self.FortyMinutesView.layer.borderWidth = 1
        self.FortyMinutesView.backgroundColor = .black
        self.FortyMinutesView.layer.borderColor = UIColor.white.cgColor
        
        self.TenMinutesView.layer.borderWidth = 1
        self.TenMinutesView.backgroundColor = .black
        self.TenMinutesView.layer.borderColor = UIColor.white.cgColor
        
        checkAvaliableLinks()
        
        self.resumoView.layer.cornerRadius = 10
        self.textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        self.textView.textAlignment = NSTextAlignment.justified
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let leituraVC = segue.destination as? LeituraViewController {
            
            leituraVC.cod_resumo = self.selectedResumo?.cod_resumo
            
            let authorsList = self.selectedResumo?.autores
            let joinedNames =  Util.joinAuthorsNames(authorsList: authorsList!)
            
            leituraVC.author = joinedNames
            
            leituraVC.episodeTitle = self.selectedResumo?.titulo
            leituraVC.resumoText = textView.text
        }
        
    }
    @IBAction func clickORSwipeUp(_ sender: Any) {
        
        performSegue(withIdentifier: "goto_leitura", sender: self)
    }
    
    
    @IBAction func clickSalvar(_ sender: Any) {
        
        let cod_resumo = self.selectedResumo?.cod_resumo
        
        let resumos = self.realm.objects(ResumoEntity.self)
            .filter("cod_resumo = %@", cod_resumo);
        
        if let resumo = resumos.first {
            
            try! self.realm.write {
                
                if resumo.favoritado == 0 {
                    resumo.favoritado = 1
                    btnSalvar.image = UIImage(named: "favoritoOrange")!
                    btnSalvar.tintColor = UIColor.init(hex: 0xFF8633)
                } else {
                    resumo.favoritado = 0
                    btnSalvar.image = UIImage(named: "favoritoWhite")!
                    btnSalvar.tintColor = UIColor.white
                }
                
                NSLog("favorito resumo %@", resumo.cod_resumo)
            }
        }
        
    }
    
    @IBAction func clickDownload(_ sender: Any) {
        //Marking as downloaded
        let cod_resumo = self.selectedResumo?.cod_resumo
        let resumos = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo)
        guard let resumo = resumos.first else {
//            Toast(text: "Não foi possivel fazer o download", duration: 1).show()
//            Delay.short
            print("Não foi possivel fazer o download")
            return
        }
        try! self.realm.write {
            resumo.downloaded = 1
            
            NSLog("downloaded resumo %@", resumo.cod_resumo)
        }
//        Toast(text: "Download em andamento", duration: 1).show()
        print("Download em andamento")

        
        //Saving files
        AppService.util.dowanloadAudio(urlSring: (self.selectedResumo?.url_podcast_40_f)!)
        AppService.util.dowanloadAudio(urlSring: (self.selectedResumo?.url_podcast_10)!)

        
    }
}

extension DetalheViewController: contentViewDelegate {
    func viewClicked() {
        
    }
}
