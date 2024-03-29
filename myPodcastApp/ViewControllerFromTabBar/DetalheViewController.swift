//
//  DetalheViewController.swift
//  myPodcastApp
//
//  Created by William on 15/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Toast_Swift
import Reachability

enum episodeType: String {
    case fortyFree = "url_podcast_40_f"
    case fortyPremium = "url_podcast_40_p"
    case ten = "url_podcast_10"
}

enum enum_cod_tipo_consumo: String {
    case fortyFree = "1"
    case fortyPremium = "2"
    case tenPodcast = "3"
    case tenTexto = "4"
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
    
    
    
    //New buttons
    
    var selectedResumo : Resumo?
    var success: Bool?
    var resumoDetails: [String: AnyObject]?
    var error_msg: String?
    let reachability = Reachability()!
    
    var error_msgPing:String?
    var successPing:Bool?
//    lazy var downloadsSession: URLSession = {
//        let configuration = URLSessionConfiguration.default
//        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
//    }()

    
    //TODO Trocar isso que ta ai
    var cod_tipo_consumo: String?

    let updateInterval = 0.5
    var timer: Timer?
    var realm = AppService.realm()
    var needsUpdate = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        AppService.downloadService.downloadsSession = downloadsSession

        self.superResizableView = resizableView
        self.superBottomConstraint = resizableBottomConstraint
        
        setupUI()
        
        //check Internet
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                self.checkAvaliableLinks()
            }
        }
        reachability.whenUnreachable = { _ in
            self.useLocalData()
        }
        
        episodeContentView.delegate = self
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(self.getDataFromRealm), userInfo: nil, repeats: true)
        }
        getDataFromRealm()
        updateContent()

        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsUpdate(_:)), name: .downloadDidComplete, object: nil)

    }
    
    @objc func setNeedsUpdate(_ notification: Notification) {
        getDataFromRealm()
        updateContent()
    }
    
    @objc func getDataFromRealm() {
        AppService.downloadService.fixDownloadingOnRealm()
        self.realm = AppService.realm()
        
        let resumos = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", selectedResumo?.cod_resumo)
        guard let resumo = resumos.first else {
            print("ERRO ao achar resumo")
            return
        }
        
        if resumo.downloading == 1 {
            self.needsUpdate = true
        }
        
        if self.needsUpdate {
            updateContent()
        }
        self.needsUpdate = false
    }
    
    func updateContent() {
        self.realm = AppService.realm()
        let resumoEntity = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.selectedResumo?.cod_resumo).first
        
        var isDownaloded = false
        var isDownloading = false
        
        if resumoEntity?.downloaded == 1 {
            isDownaloded = true
        }
        if resumoEntity?.downloading == 1 {
            isDownloading = true
        }
        let resumo = Resumo(resumoEntity: resumoEntity!)
        DispatchQueue.main.async {
            //FavoritoBtn
            if resumo.favoritado == 1 {
                self.episodeContentView.setFavoritoBtn(favoritado: true)
            }
            else {
                self.episodeContentView.setFavoritoBtn(favoritado: false)
            }
            
            //DownaloadBtn
            let progress = resumo.progressDownload
            self.episodeContentView.updateDisplay(progress: progress)

            self.episodeContentView.changeDownloadButtonLook(isDownloading: isDownloading, isDownloaded: isDownaloded)
        }
    }
    
    func setupActionButtons() {
        let cod_resumo = selectedResumo?.cod_resumo
        let resumos = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo!)
        if let resumo = resumos.first {
            
            // verificar se eh favorito
            if resumo.favoritado == 1 {
                episodeContentView.favoritoBtn.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
                episodeContentView.favoritoBtn.tintColor = UIColor.init(hex: 0xFF8633)
            } else {
                episodeContentView.favoritoBtn.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
                episodeContentView.favoritoBtn.tintColor = UIColor.white
            }
            
            // verificar se eh downloaded
            if resumo.downloaded == 1 {
                episodeContentView.downloadBtn.setImage(UIImage(named: "downloadOrange")!, for: .normal)
                episodeContentView.downloadBtn.tintColor = UIColor.init(hex: 0xFF8633)
            } else {
                episodeContentView.downloadBtn.setImage(UIImage(named: "downloadWhite")!, for: .normal)
                episodeContentView.downloadBtn.tintColor = UIColor.white
            }
        }
    }
    
    func useLocalData() {
        let cod_resumo = self.selectedResumo?.cod_resumo
        let resumos = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo)
        if let resumo = resumos.first {
            if resumo.downloaded == 1 {
                self.fortyMinutesButton.isEnabled = true
                self.resumo10Btn.isEnabled = true
            }
        }

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
        //Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(onFullPlayerShouldAppear(_:)), name: .fullPlayerShouldAppear, object: nil)

        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Reachability notifier")
        }
        
        //////////////////////////DOWNALOD/////////
        let userIsPremium = false
        var urlString: String?
        if userIsPremium {
            urlString = selectedResumo?.url_podcast_40_p
        }
        else {
            urlString = selectedResumo?.url_podcast_40_f
        }
        let url = URL(string: urlString!)
        
        if let down = AppService.downloadService.activeDownloads[url!] {
            episodeContentView.download = down
            episodeContentView.download?.tableViewIndex = -1
        }
        else {
            episodeContentView.download = Download(resumo: selectedResumo!)
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.connection == .wifi || reachability.connection == .cellular {
            print("Conected")
        }
    }
    
    @objc func onFullPlayerShouldAppear(_ notification: Notification) {
        self.fortyMinutesButton.isHidden = false
        self.fortyLoading.isHidden = true
        self.fortyLoading.stopAnimating()
        
        self.tenMinutesButton.isHidden = false
        self.tenLoading.isHidden = true
        self.tenLoading.stopAnimating()

    }
    
    func checkAvaliableLinks() {
        //TODO change this for checking the user info
        var userIsPremium = true
        
        var canUse40 = true
        var canUse10 = false
        var canUseResumo = true
        
        if userIsPremium {
            canUse10 = true
        }
        if canUse10 {
            if selectedResumo?.url_podcast_10 != nil && selectedResumo?.url_podcast_10 != "" {
                tenMinutesButton.isEnabled = true
            }
        }
        if canUse40 {
            if selectedResumo?.url_podcast_40_f != nil && selectedResumo?.url_podcast_40_f != "" {
                fortyMinutesButton.isEnabled = true
            }
        }
        if canUseResumo {
            if selectedResumo?.resumo_10 != nil && selectedResumo?.resumo_10 != "" {
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
        
        //TODO: remove on 2.0
        if senderObject.isEqual(self.tenMinutesButton) {
            guard let premiumVC = storyboard?.instantiateViewController(
                withIdentifier: "PremiumViewController")
                as? PremiumViewController else {
                    assertionFailure("No view controller ID PremiumViewController in storyboard")
                    return
            }
            present(premiumVC, animated: true, completion: nil)
            return
        }
        
        //TEN and Downloaded
        if senderObject.isEqual(self.tenMinutesButton) && resumo?.downloaded == 1 {
            cod_tipo_consumo = enum_cod_tipo_consumo.tenPodcast.rawValue

            mEpisodeType = episodeType.ten
            episodeLink = chooseLocalURLorServer(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_10)!)!)
        }
        //TEN not downloaded
        else if senderObject.isEqual(self.tenMinutesButton) &&  resumo?.downloaded == 0 {
            
            if AppService.util.isConnectedToNetwork() == false {
                AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
                return
            }
            
            cod_tipo_consumo = enum_cod_tipo_consumo.tenPodcast.rawValue

            mEpisodeType = episodeType.ten
            episodeLink = URL(string: (self.selectedResumo?.url_podcast_10)!)!
            self.tenMinutesButton.isHidden = true
            self.tenLoading.isHidden = false
            self.tenLoading.startAnimating()
            
            //Case the user click the other buttom while waiting for the firt to load
            self.fortyMinutesButton.isHidden = false
            self.fortyLoading.isHidden = true
            self.fortyLoading.stopAnimating()
        }
        //FORTY downloaded
        else if senderObject.isEqual(self.fortyMinutesButton) &&  resumo?.downloaded == 1 {
            if userIsPremium {
                cod_tipo_consumo = enum_cod_tipo_consumo.fortyPremium.rawValue

                mEpisodeType = episodeType.fortyPremium
                episodeLink = chooseLocalURLorServer(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_40_p)!)!)
            }
            else {
                cod_tipo_consumo = enum_cod_tipo_consumo.fortyFree.rawValue

                mEpisodeType = episodeType.fortyFree
                episodeLink = chooseLocalURLorServer(sender: sender, serverUrl: URL(string: (self.selectedResumo?.url_podcast_40_f)!)!)
            }
            
        }
        //FORTY not downloaded
        else {
            if AppService.util.isConnectedToNetwork() == false {
                AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
                return
            }
            if userIsPremium {
                cod_tipo_consumo = enum_cod_tipo_consumo.fortyPremium.rawValue

                mEpisodeType = episodeType.fortyPremium
                episodeLink = URL(string: (self.selectedResumo?.url_podcast_40_p)!)!
            }
            else {
                cod_tipo_consumo = enum_cod_tipo_consumo.fortyFree.rawValue
                mEpisodeType = episodeType.fortyFree
                episodeLink = URL(string: (self.selectedResumo?.url_podcast_40_f)!)!
            }
            
            self.fortyMinutesButton.isHidden = true
            self.fortyLoading.isHidden = false
            self.fortyLoading.startAnimating()
            
            //Case the user click the other buttom while waiting for the firt to load
            self.tenMinutesButton.isHidden = false
            self.tenLoading.isHidden = true
            self.tenLoading.stopAnimating()
        }

        do {
            let userIsAllowedToPlay = try playerManager.shared.episodeSelected(episode: selectedResumo!, episodeLink: episodeLink, episodeType: mEpisodeType, preLoadedAVItem: nil)
            
            if !userIsAllowedToPlay {
                AppService.util.handleNotAllowed()
            }
            else {
                preparePing(cod_resumo: (selectedResumo?.cod_resumo)!, cod_tipo_consumo: self.cod_tipo_consumo!)
            }
            
        } catch AppError.urlError {
            print("URL ERROR")
        } catch {
            print("episodeSelected ERROR unknown")
        }
    }
    
    func preparePing(cod_resumo: String, cod_tipo_consumo: String) {
        let link = AppConfig.urlBaseApi + "consumirResumo.php"
        let url = URL(string: link)
        let keys = ["cod_usuario", "cod_resumo", "cod_tipo_consumo"]
        
        
        let prefs:UserDefaults = UserDefaults.standard
        var cod_usuario = prefs.string(forKey: "cod_usuario")
        if cod_usuario == nil || cod_usuario == "" {
            cod_usuario = "0"
        }
        
        var values = [String]()
        values.append(cod_usuario!)
        values.append(cod_resumo)
        values.append(self.cod_tipo_consumo!)
        makeResquestPing(url: url!, keys: keys, values: values)
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
        self.resumo10View.layer.borderColor = UIColor.white.cgColor
        self.FortyMinutesView.layer.borderColor = UIColor.white.cgColor
        
        self.TenMinutesView.layer.borderWidth = 1
        self.TenMinutesView.layer.cornerRadius = 10
        self.TenMinutesView.layer.borderColor = UIColor.init(hex: 0xA25520).cgColor

        self.resumo10View.layer.borderWidth = 1
        self.resumo10View.layer.cornerRadius = 10
        self.resumo10View.layer.borderColor = UIColor.init(hex: 0xA25520).cgColor
        
        self.resumoView.layer.cornerRadius = 10
        
        self.textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        self.textView.text = AppService.util.populateString(selectedResumo?.subtitulo as AnyObject)
        print(self.textView.text)
        self.textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        
        setupActionButtons()
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
        //TODO: remove on 2.0
        guard let premiumVC = storyboard?.instantiateViewController(
            withIdentifier: "PremiumViewController")
            as? PremiumViewController else {
                assertionFailure("No view controller ID PremiumViewController in storyboard")
                return
        }
        cod_tipo_consumo = enum_cod_tipo_consumo.tenTexto.rawValue
        preparePing(cod_resumo: (self.selectedResumo?.cod_resumo)!, cod_tipo_consumo: self.cod_tipo_consumo!)
        present(premiumVC, animated: true, completion: nil)
        
//        performSegue(withIdentifier: "goto_leitura", sender: self)
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
//            let updatedResumoEntity = resumoEntity?.addDescription(episodeDetailedDictonary: self.resumoDetails!)
            
//            self.selectedResumo = Resumo(resumoEntity: updatedResumoEntity!)
            
        }
        else {
            AppService.util.alert("Erro ao encontrar detalhes da resumo", message: error_msg!)
        }
        
    }
}

//PING
extension DetalheViewController {
    
    func makeResquestPing(url: URL, keys: [String], values: [String]) {
        var request = URLRequest(url: url)
        let session = URLSession.shared
        
        let tuples = zip(keys, values)
        var keyValueArray = [String]()
        for (key, value) in tuples {
            let paramValue = key + "=" + value
            keyValueArray.append(paramValue)
        }
        let joinedData = keyValueArray.joined(separator: "&")
        
        //        let postData:Data = joinedData.data(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue))!
        //        let postLength:NSString = String( postData.count ) as NSString
        
        let post = joinedData as NSString
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        let postLength:NSString = String( postData.count ) as NSString
        
        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.httpBody = postData
        
        //        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        print("REQUEST: \(request)")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print(error)
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            self.extract_json_dataPing(dataString!)
            
        })
        
        task.resume()
    }
    
    func extract_json_dataPing(_ data:NSString) {
        
        NSLog("json %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            self.successPing = (json.value(forKey: "success") as! Bool)
            if (self.successPing!) {
                
                NSLog("SugerirVC SUCCESS");
            } else {
                
                NSLog("SugerirVC ERROR");
                error_msg = (json.value(forKey: "error") as! String)
                
            }
        }
        catch
        {
            print("error SugerirVC")
            return
        }
        DispatchQueue.main.async(execute: onResultReceivedPing)
        
    }
    
    func onResultReceivedPing() {
        
        if self.successPing! {
            print("success no Ping")
        }
        else {
            print("Erro no Ping")
        }
        
    }
}

extension DetalheViewController: downloadFavoritoDelegate {
    func confirmDownloadDeletion(resumo: Resumo?, urlString: String) {
        let alert = UIAlertController(
            title: "Remover Resumo",
            message: "Deseja remover o download do resumo ?",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Remover", style: UIAlertAction.Style.destructive, handler:{(ACTION :UIAlertAction) in
            self.needsUpdate = true
            
            guard let _ = resumo else {
                return
            }
            
            AppService.util.deleteResumoAudioFile(urlString: urlString, cod_resumo: resumo!.cod_resumo)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.cancel, handler:{(ACTION :UIAlertAction) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func clickDownload() {
        //        getDataFromRealm()
    }
    
    func downloadCanceled() {
        needsUpdate = true
    }
    
    func clickFavorito() {
        needsUpdate = true
    }
    
    
}

