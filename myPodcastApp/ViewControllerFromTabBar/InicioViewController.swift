//
//  InicioViewController.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ImageSlideshow
import RealmSwift

class InicioViewController: InheritanceViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resizableView: UIView!
    @IBOutlet weak var resizableBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    // MARK: - Properties
    var error_msg:String!
    var success:Bool!
    
//    var selectedEpisode : [String: AnyObject]?
    var selectedResumo : Resumo?
    var selectedResumoImage : UIImage?
    var episodesArray :[[String:AnyObject]]?
    var resumoArray = [Resumo]()
    
    let realm = AppService.realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.superResizableView = resizableView
        self.superBottomConstraint = resizableBottomConstraint
        
        
        slideShow.layer.cornerRadius = 10
        slideShow.clipsToBounds = true
        
        
        loading.isHidden = true
        
        
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "banner")!),
            ImageSource(image: UIImage(named: "banner")!),
            //AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
            //KingfisherSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
            //ParseSource(file: PFFile(name:"image.jpg", data:data))
        ])
        
        
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.init(hex: 0xFF8633) //UIColor.darkGray //
        pageIndicator.pageIndicatorTintColor = UIColor.white
        slideShow.pageIndicator = pageIndicator
        
        slideShow.circular = true
        
        slideShow.contentScaleMode = UIView.ContentMode.scaleToFill
        

        setupUI()

        //getting Data
        makeResquest()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        //if !playerManager.shared.getPlayerIsSet() {
            //self.superBottomConstraint?.constant = 0
        //}
        
        self.tableView.reloadData()
    }
    
    /*private func populateDefaultCategories() {
        
        if resumos.count == 0 {
            
            try! realm.write() {
                for episode in episodesArray! {
                    let newResumo = Resumo()
                    newResumo.cod_resumo = episode["cod_resumo"] as! String
                    newResumo.titulo = episode["titulo"] as! String
                    
                    if (Util.nullToNil(value: episode["url_podcast_10"]) != nil) {
                        newResumo.url_podcast_10 = episode["url_podcast_10"] as! String
                    }
                    if (Util.nullToNil(value: episode["url_podcast_40_f"]) != nil) {
                        newResumo.url_podcast_40_f = episode["url_podcast_40_f"] as! String
                    }
                    if (Util.nullToNil(value: episode["url_podcast_40_p"]) != nil) {
                        newResumo.url_podcast_40_p = episode["url_podcast_40_p"] as! String
                    }
                    
                    //                    let authorsList = resumoDict["autores"] as! [[String : AnyObject]]
                    //                    newResumo. = Util.joinStringWithSeparator(authorsList:
                    
                    realm.add(newResumo)
                }
                resumos = realm.objects(Resumo.self)
            }
            
        }
        
    }*/
    
    
    func setupUI() {
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        setupNavBarTitle()
    }
    
    func setupNavBarTitle() {
        //
        //        let paragraph = NSMutableParagraphStyle()
        //        paragraph.alignment = .center
        //        let myAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraph]
        //
        //        let greetingsMessage = NSLocalizedString("welcome", comment: "ola")
        //        let attributedText = NSMutableAttributedString(string: greetingsMessage, attributes: myAttributes)
        //        navigationController?.navigationBar.titleTextAttribute =  attributedText
        //
        
        //        let paragraph = NSMutableParagraphStyle()
        //        paragraph.alignment = .center
        //
        //        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.paragraphStyle: paragraph]
        //
        //        navigationController?.navigationBar.titleTextAttributes = attributes
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
extension InicioViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodesCounter = episodesArray?.count else {
            return 0
        }
        return episodesCounter
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        let resumo = self.resumoArray[indexPath.row]
        
        let cod_resumo = resumo.cod_resumo
        
        cell.titleLabel.text = resumo.titulo
        let authorsList = resumo.autores
        cell.authorLabel.text = Util.joinAuthorsNames(authorsList: authorsList)
        let coverUrl = resumo.url_imagem
        
        //When return from detailsVC
        cell.goBackToOriginalColors()
        
        cell.coverImg.image = UIImage(named: "cover_placeholder")!
        if AppService.util.isNotNull(coverUrl as AnyObject?) {
            AppService.util.load_image_resumo(coverUrl, cod_resumo: cod_resumo, imageview: cell.coverImg)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detalheVC = segue.destination as? DetalheViewController {
            detalheVC.selectedResumo = self.selectedResumo
            detalheVC.selectedResumoImage = self.selectedResumoImage
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomCell
        
        self.selectedResumo = self.resumoArray[indexPath.row]
        self.selectedResumoImage = cell.coverImg.image
        
        performSegue(withIdentifier: "to_detail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomCell
        
        //cell.setHighlightColor()
        
        cell.goBackToOriginalColors()
    }
}

extension InicioViewController {
    
    func makeResquest() {
        
        loading.isHidden = false
        loading.startAnimating()
        
        
        let link = AppConfig.urlBaseApi + "buscaResumos.php"
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
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
                
                NSLog("Login SUCCESS");
                // dados do json
                self.episodesArray = (json.object(forKey: "resumos") as! Array)
                
            } else {
                
                NSLog("Login ERROR");
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
        
        loading.isHidden = true
        loading.stopAnimating()
        
        if self.success {
            
            // zerar dados
            /*for entity in realm.objects(Resumo.self) {
                try! realm.write {
                    self.realm.delete(entity)
                }
            }*/
            
            
            for resumoDict in self.episodesArray! {
                
                let cod_resumo = resumoDict["cod_resumo"] as! String
                
                //
                var resumoInit = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
                
                if resumoInit == nil {
                    resumoInit = ResumoEntity()
                    resumoInit!.cod_resumo = cod_resumo
                }
                
                let resumoEntity = resumoInit!
                
                try! realm.write {
                    resumoEntity.titulo = AppService.util.populateString(resumoDict["titulo"] as AnyObject)
                    resumoEntity.subtitulo = AppService.util.populateString(resumoDict["subtitulo"] as AnyObject)
                    resumoEntity.temporada = AppService.util.populateString(resumoDict["temporada"] as AnyObject)
                    resumoEntity.episodio = AppService.util.populateString(resumoDict["episodio"] as AnyObject)
                    resumoEntity.url_imagem = AppService.util.populateString(resumoDict["url_imagem"] as AnyObject)
                    resumoEntity.url_podcast_10 = AppService.util.populateString(resumoDict["url_podcast_10"] as AnyObject)
                    resumoEntity.url_podcast_40_p = AppService.util.populateString(resumoDict["url_podcast_40_p"] as AnyObject)
                    resumoEntity.url_podcast_40_f = AppService.util.populateString(resumoDict["url_podcast_40_f"] as AnyObject)
                    resumoEntity.resumo_10 = AppService.util.populateString(resumoDict["resumo_10"] as AnyObject)
                    
                    let authorsDictList = resumoDict["autores"] as! [[String : AnyObject]]
                    for authorDict in authorsDictList {
                        let newAutorEntity = AutorEntity(autorDictonary: authorDict)
                        resumoEntity.autores.append(newAutorEntity!)
                    }
                    
                    self.realm.add(resumoEntity, update: true)
                    NSLog("save resumo %@ - %@", resumoEntity.cod_resumo, resumoEntity.titulo)
                    
                    //Building Model
                    let newResumo = Resumo(resumoEntity: resumoEntity)
                    self.resumoArray.append(newResumo)
                }
                
            }
            
            self.tableView.reloadData()
            
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg!)
        }
        
    }
    
}
