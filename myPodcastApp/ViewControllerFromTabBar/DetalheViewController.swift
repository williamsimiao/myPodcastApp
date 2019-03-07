//
//  DetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
//import Toaster

enum linkType: String {
    case fortyFree = "url_podcast_40_f"
    case fortyPremium = "url_podcast_40_p"
    case ten = "url_podcast_10"
}


class DetalheViewController: InheritanceViewController {
    
    @IBOutlet weak var episodeContentView: epidodeContentRightView!
    @IBOutlet weak var FortyMinutesView: UIView!
    @IBOutlet weak var fortyMinutesButton: UIButton!
    
    @IBOutlet weak var TenMinutesView: UIView!
    @IBOutlet weak var tenMinutesButton: UIButton!
    
    @IBOutlet weak var resizableView: UIView!
    
    @IBOutlet weak var resizableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var resumoView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var btnDownload: UIBarButtonItem!
    
    @IBOutlet weak var btnSalvar: UIBarButtonItem!
    
    var realm = AppService.realm()
    
    
//    var selectedEpisode : [String: AnyObject]?
    var selectedResumo : Resumo?
    var selectedResumoImage : UIImage?
    var success: Bool?
    var detailsEpisode: [String: AnyObject]?
    var error_msg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.navigationBar.prefersLargeTitles = false
        
        self.superResizableView = resizableView
        self.superBottomConstraint = resizableBottomConstraint
        
        //makeResquest()
        
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
    
    func makeResquest() {
        let cod_resumo = selectedResumo?.cod_resumo
        
        //        let url:URL = createURLWithComponents(cod_resumo: cod_resumo)!
        let urlString = AppConfig.urlBaseApi + "detalheResumo.php" + "?cod_resumo=" + cod_resumo!
        let myUrl = URL(string: urlString)
        
        let session = URLSession.shared
        
        var request = URLRequest(url: myUrl!)
        
        request.timeoutInterval = 10
        request.httpMethod = "GET"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            self.extract_json_data(dataString!)
        })
        task.resume()
    }
    
    func extract_json_data(_ data:NSString) {
        
        NSLog("FILO %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do {
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            self.success = (json.value(forKey: "success") as! Bool)
            if (self.success!) {
                
                NSLog("Login SUCCESS");
                self.detailsEpisode = (json.object(forKey: "resumo") as! Dictionary)
            } else {
                NSLog("Login ERROR");
                error_msg = (json.value(forKey: "error") as! String)
            }
        }
        catch {
            print("error")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {
        
        if self.success! {
            
            let resumo = (detailsEpisode!["resumo_10"] as! String)
            
            textView.text = resumo
            
            if resumo == "" {
                resumoView.isHidden = true
                //textView.text = exempleText
            }
            else {
                resumoView.isHidden = false
            }
            
        }
        else {
            AppService.util.alert("Erro na Detail", message: error_msg!)
        }
        
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
        }
        else if senderObject.isEqual(self.fortyMinutesButton) &&  resumo?.downloaded == 1 {
            episodeLink = getLocalURL(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_40_f)!)!)
        }
        else {
            episodeLink = URL(string: (self.selectedResumo?.url_podcast_40_f)!)!
        }

        playerManager.shared.episodeSelected(episode: selectedResumo!, episodeLink: episodeLink)
        
        NotificationCenter.default.post(name: .fullPlayerShouldAppear, object: self, userInfo: nil)
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
