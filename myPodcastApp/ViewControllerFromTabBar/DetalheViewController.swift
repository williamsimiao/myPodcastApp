//
//  DetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Toast_Swift

enum episodeType: String {
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
    
    @IBOutlet weak var resumo10View: UIView!
    @IBOutlet weak var resumo10Btn: UIButton!
    
    
    @IBOutlet weak var resizableView: UIView!
    
    @IBOutlet weak var resizableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var resumoView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var btnDownload: UIBarButtonItem!
    
    @IBOutlet weak var btnSalvar: UIBarButtonItem!
    
    var realm = AppService.realm()
    
    var selectedResumo : Resumo?
    var success: Bool?
    var resumoDetails: [String: AnyObject]?
    var error_msg: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.superResizableView = resizableView
        self.superBottomConstraint = resizableBottomConstraint
        
        let detalhesUrl = AppService.util.createURLWithComponents(path: "detalheResumo.php", parameters: ["cod_resumo"], values: [(self.selectedResumo?.cod_resumo)!])
        makeResquest(url: detalhesUrl!)
        
        episodeContentView.delegate = self
        setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //TODO check why isHidden from interfaceBuilder is being overwritten
        if self.fortyLoading.isHidden {
            print("IS HIDEN")
        }
        else {
            print("NOT HIDEN")
        }
        self.fortyLoading.isHidden = true
        self.tenLoading.isHidden = true
    }
    
    func checkAvaliableLinks() {
        //TODO change this for checking the user info
        var userIsPremium = false
        
        var canUse40 = true
        var canUse10 = false
        var canUseResumo = true
        
        if userIsPremium {
            canUse10 = true
        }
        if canUse10 {
            if selectedResumo?.url_podcast_10 != nil && selectedResumo?.url_podcast_10 == "" {
                tenMinutesButton.isEnabled = true
            }
        }
        if canUse40 {
            if selectedResumo?.url_podcast_40_f == nil && selectedResumo?.url_podcast_40_f == "" {
                fortyMinutesButton.isEnabled = true
            }
        }
        if canUseResumo {
            if selectedResumo?.resumo_10 == nil && selectedResumo?.resumo_10 == "" {
                let teste = selectedResumo?.resumo_10
                resumo10Btn.isEnabled = true
            }
        }
    }
    
    @IBAction func clickPlayButton(_ sender: Any) {
        //TODO: trocar essa variavel por acesso a API
        let userIsPremium = false
        
        let episodeLink : URL
        let mEpisodeType: episodeType
        
        let resumo = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.selectedResumo?.cod_resumo as Any).first
        let senderObject = sender as AnyObject
        
        //TEN and Downloaded
        if senderObject.isEqual(self.tenMinutesButton) &&  resumo?.downloaded == 1 {
            mEpisodeType = episodeType.ten
            episodeLink = chooseLocalURLorServer(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_10)!)!)
        }
        //TEN not downloaded
        else if senderObject.isEqual(self.tenMinutesButton) &&  resumo?.downloaded == 0 {
            mEpisodeType = episodeType.ten
            episodeLink = URL(string: (self.selectedResumo?.url_podcast_10)!)!
//            self.tenMinutesButton.isHidden = true
//            self.tenLoading.isHidden = false
//            self.tenLoading.startAnimating()
        }
        //FORTY downloaded
        else if senderObject.isEqual(self.fortyMinutesButton) &&  resumo?.downloaded == 1 {
            if userIsPremium {
                mEpisodeType = episodeType.fortyPremium
                episodeLink = chooseLocalURLorServer(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_40_p)!)!)
            }
            else {
                mEpisodeType = episodeType.fortyFree
                episodeLink = chooseLocalURLorServer(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_40_f)!)!)
            }
            
        }
        //FORTY not downloaded
        else {
            if userIsPremium {
                mEpisodeType = episodeType.fortyPremium
                episodeLink = URL(string: (self.selectedResumo?.url_podcast_40_p)!)!
            }
            else {
                mEpisodeType = episodeType.fortyFree
                episodeLink = URL(string: (self.selectedResumo?.url_podcast_40_f)!)!
            }
            if (self.fortyLoading.isHidden) {
                print("OI")
            }
//            self.fortyMinutesButton.isHidden = true
//            self.fortyLoading.isHidden = false
//            self.fortyLoading.startAnimating()
        }

        let userIsAllowedToPlay = playerManager.shared.episodeSelected(episode: selectedResumo!, episodeLink: episodeLink, episodeType: mEpisodeType)
        
        if userIsAllowedToPlay {            
            NotificationCenter.default.post(name: .fullPlayerShouldAppear, object: self, userInfo: nil)
        }
        else {
            AppService.util.handleNotAllowed()
        }
    }
    
    func chooseLocalURLorServer(sender: Any, serverUrl: URL) -> URL {
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
        AppService.util.load_image_resumo((selectedResumo?.url_imagem)!, cod_resumo: (selectedResumo?.cod_resumo)!, imageview:  self.episodeContentView.coverImg!)
        
        self.FortyMinutesView.layer.borderWidth = 1
        self.FortyMinutesView.layer.cornerRadius = 10
        self.FortyMinutesView.backgroundColor = .black
        self.FortyMinutesView.layer.borderColor = UIColor.white.cgColor
        
        self.TenMinutesView.layer.borderWidth = 1
        self.TenMinutesView.layer.cornerRadius = 10
        self.TenMinutesView.backgroundColor = .black
        self.TenMinutesView.layer.borderColor = UIColor.white.cgColor

        self.resumo10View.layer.borderWidth = 1
        self.resumo10View.layer.cornerRadius = 10
        self.resumo10View.backgroundColor = .black
        self.resumo10View.layer.borderColor = UIColor.white.cgColor

        checkAvaliableLinks()
        
        self.resumoView.layer.cornerRadius = 10
        self.textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        self.textView.textAlignment = NSTextAlignment.justified
        
        let cod_resumo = selectedResumo?.cod_resumo
        
        let resumos = self.realm.objects(ResumoEntity.self)
            .filter("cod_resumo = %@", cod_resumo!);
        if let resumo = resumos.first {
            
            // verificar se eh favorito
            if resumo.favoritado == 1 {
                btnSalvar.image = UIImage(named: "favoritoOrange")!
                btnSalvar.tintColor = UIColor.init(hex: 0xFF8633)
            } else {
                btnSalvar.image = UIImage(named: "favoritoWhite")!
                btnSalvar.tintColor = UIColor.white
            }
            
            // verificar se eh downloaded
            if resumo.downloaded == 1 {
                btnDownload.image = UIImage(named: "downloadOrange")!
                btnDownload.tintColor = UIColor.init(hex: 0xFF8633)
            } else {
                btnDownload.image = UIImage(named: "downloadWhite")!
                btnDownload.tintColor = UIColor.white
            }
        }
    }
    
    func setUpResumoDescriptionView() {
        let theDescription = self.selectedResumo?.descricao
        textView.text = theDescription
        
        if theDescription == "" {
            resumoView.isHidden = true
        }
        else {
            resumoView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let leituraVC = segue.destination as? LeituraViewController {
            
            leituraVC.cod_resumo = self.selectedResumo?.cod_resumo
            
            let authorsList = self.selectedResumo?.autores
            let joinedNames =  Util.joinAuthorsNames(authorsList: authorsList!)
            
            leituraVC.author = joinedNames
            leituraVC.episodeTitle = self.selectedResumo?.titulo
            leituraVC.resumoText = self.selectedResumo?.resumo_10
            leituraVC.currentResumo = self.selectedResumo
        }
        
    }
    @IBAction func clickLeituraBtn(_ sender: Any) {
        
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
        //        Toast(text: "Download em andamento", duration: 1).show()
        print("Download em andamento")

        
        //Saving files
        let userIsPremium = false
        if userIsPremium {
            AppService.util.downloadAudio(urlString: (self.selectedResumo?.url_podcast_40_p)!, cod_resumo: cod_resumo!)
            AppService.util.downloadAudio(urlString: (self.selectedResumo?.url_podcast_10)!, cod_resumo: cod_resumo!)
        }
        else {
            AppService.util.downloadAudio(urlString: (self.selectedResumo?.url_podcast_40_f)!, cod_resumo: cod_resumo!)
        }
        

    }
    
    func stopAnimations() {
        self.fortyLoading.stopAnimating()
        self.fortyLoading.isHidden = true
        
        self.tenLoading.stopAnimating()
        self.tenLoading.isHidden = true
    }
}

//RESQUEST
extension DetalheViewController {
    func makeResquest(url: URL) {
        var request = URLRequest(url: url)
        let session = URLSession.shared
        
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
        
        NSLog("json %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            self.success = (json.value(forKey: "success") as! Bool)
            if (self.success!) {
                NSLog("Detalhes SUCCESS");
                self.resumoDetails = (json.object(forKey: "resumo") as! Dictionary)
                
            } else {
                
                NSLog("Detalhes ERROR");
                error_msg = (json.value(forKey: "error") as! String)
            }
        }
        catch
        {
            print("error")
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {
        
        if self.success! {
            print("Detalhes recebidos")
            
            //Getting the ResumoEntity
            let resumoEntity = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.selectedResumo?.cod_resumo as Any).first
            
            //Saiving description on dataBase
            let updatedResumoEntity = resumoEntity?.addDescription(episodeDetailedDictonary: self.resumoDetails!)
            
            self.selectedResumo = Resumo(resumoEntity: updatedResumoEntity!)

            
            setUpResumoDescriptionView()
        }
        else {
            AppService.util.alert("Erro encontrar detalhes da resumo", message: error_msg!)
        }
        
    }
}


extension DetalheViewController: contentViewDelegate {
    func viewClicked() {
        
    }
}
