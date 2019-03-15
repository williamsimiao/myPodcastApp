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
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var authorCollectionView: UICollectionView!
    
    @IBOutlet weak var topResumosCollectionView: UICollectionView!
    
    @IBOutlet weak var top10Label: UILabel!
    @IBOutlet weak var ultimosLabel: UILabel!
    @IBOutlet weak var autoresLabel: UILabel!
    
    // MARK: - Properties
    var error_msg:String!
    var success:Bool!
    
//    var selectedEpisode : [String: AnyObject]?
    var selectedResumo : Resumo?
    
    var topResumosDictArray :[[String:AnyObject]]?
    var ultimosResumosDictArray :[[String:AnyObject]]?
    var autoresDictArray :[[String:AnyObject]]?

    var topResumos = [Resumo]()
    var ultimosResumos = [Resumo]()
    var autoresArray = [Autor]()
    
    let realm = AppService.realm()
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.superResizableView = resizableView
//        self.superBottomConstraint = resizableBottomConstraint
        
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
        
        createSearchBar()
        setupUI()

        //getting Data
        makeResquest()
        
    }
    
    func createSearchBar() {
//        let searchBarController = UISearchBar()
//        searchBarController.placeholder = "Pesquisar"

        //NAvigation setup
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.tintColor = .white
        searchController.searchBar.placeholder = "Pesquisar"
        
        searchController.searchBar.delegate = self
        searchController.delegate = self
        searchController.searchResultsUpdater = self

        
        self.navigationItem.searchController = searchController
        
        
        let searchBarItem = UIBarButtonItem(image: UIImage(named: "searchWhite"),  style: .plain, target: self, action: #selector(InicioViewController.clickSearchNavItem(_:)))

        navigationItem.rightBarButtonItem = searchBarItem
    }
    
    @objc func clickSearchNavItem(_ sender: UIBarButtonItem) {
        if (navigationItem.searchController?.isActive)! {
            navigationItem.hidesSearchBarWhenScrolling = true
            DispatchQueue.main.async {
                self.navigationItem.searchController?.searchBar.becomeFirstResponder()
            }
        }
        else {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        //if !playerManager.shared.getPlayerIsSet() {
            //self.superBottomConstraint?.constant = 0
        //}
        
        self.tableView.reloadData()
        self.authorCollectionView.reloadData()
        self.topResumosCollectionView.reloadData()
    }
    
    func setupUI() {
        let nibTableCell = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")
        
        let nibAuthorCollectionCell = UINib(nibName: "authorCollectionViewCell", bundle: nil)
        authorCollectionView.register(nibAuthorCollectionCell, forCellWithReuseIdentifier: "authorCollectionCell")
        
        let nibResumoCollectionCell = UINib(nibName: "resumoCollectionViewCell", bundle: nil)
        topResumosCollectionView.register(nibResumoCollectionCell, forCellWithReuseIdentifier: "resumoCollectionCell")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
extension InicioViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ultimosResumos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        
        let resumo = self.ultimosResumos[indexPath.row]
        
        let cod_resumo = resumo.cod_resumo
        
        cell.titleLabel.text = resumo.titulo
        let authorsList = resumo.autores
        let joinedNames = Util.joinAuthorsNames(authorsList: authorsList)
        cell.authorLabel.text = joinedNames
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
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! CustomCell
        
        self.selectedResumo = self.ultimosResumos[indexPath.row]
        
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
        
        
        let link = AppConfig.urlBaseApi + "home.php"
        
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
                self.topResumosDictArray = (json.object(forKey: "top10") as! Array)

                self.ultimosResumosDictArray = (json.object(forKey: "ultimos") as! Array)
                self.autoresDictArray = (json.object(forKey: "autores") as! Array)
                
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
            
            self.topResumos = convertDictArrayToResumoArray(dictResumoArray: self.topResumosDictArray!)
            self.ultimosResumos = convertDictArrayToResumoArray(dictResumoArray: self.ultimosResumosDictArray!)
            self.autoresArray = convertDictArrayToAutorArray(dictResumoArray: self.autoresDictArray!)

            self.tableView.reloadData()
            self.authorCollectionView.reloadData()
            self.topResumosCollectionView.reloadData()
            
            self.top10Label.isHidden = false
            self.ultimosLabel.isHidden = false
            self.autoresLabel.isHidden = false
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg!)
        }
        
    }
    
    func convertDictArrayToAutorArray(dictResumoArray:[[String:AnyObject]]) -> [Autor] {
        var myAutores = [Autor]()
        for autorDict in dictResumoArray {
            var autorEntity = AutorEntity()

            let cod_autor = autorDict["cod_autor"] as! String
            
            let autorInit = realm.objects(AutorEntity.self).filter("cod_autor = %@", cod_autor).first
            
            if autorInit != nil {
//                print("Autor exists on Realm")
            }
            
            autorEntity = AutorEntity(autorDictonary: autorDict)!

            try! realm.write {
                self.realm.add(autorEntity, update: true)
            }
            //Building Model
            let newAutor = Autor(autorEntity: autorEntity)
            myAutores.append(newAutor)
        }
        return myAutores
    }
    
    func convertDictArrayToResumoArray(dictResumoArray:[[String:AnyObject]]) -> [Resumo] {
        var myResumos = [Resumo]()
        for resumoDict in dictResumoArray {
            
            let cod_resumo = resumoDict["cod_resumo"] as! String
            
            let resumoInit = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
            
            if resumoInit != nil {
//                print("Resumo exists on Realm")
            }
            
            var resumoEntity = ResumoEntity()
            try! realm.write {
                resumoEntity = ResumoEntity(episodeDictonary: resumoDict)!
                self.realm.add(resumoEntity, update: true)
            }
            //Building Model
            let newResumo = Resumo(resumoEntity: resumoEntity)
            myResumos.append(newResumo)
        }
        return myResumos
    }
    
}

extension InicioViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(self.topResumosCollectionView) {
            let count = self.topResumos.count
            return count
        }
        //case is self.authorCollectionView
        else {
            let count = self.autoresArray.count
            return count
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(self.topResumosCollectionView) {
            let cell = self.topResumosCollectionView.dequeueReusableCell(withReuseIdentifier: "resumoCollectionCell", for: indexPath) as! resumoCollectionViewCell
            let resumo = self.topResumos[indexPath.row]
            
            cell.titleLabel.text = resumo.titulo
            let coverUrl = resumo.url_imagem
            
            if AppService.util.isNotNull(coverUrl as AnyObject?) {
                AppService.util.load_image_resumo(coverUrl, cod_resumo: resumo.cod_resumo, imageview: cell.coverImg)
            }
            return cell
        }
        //case is self.authorCollectionView
        else {
            let cell = self.authorCollectionView.dequeueReusableCell(withReuseIdentifier: "authorCollectionCell", for: indexPath) as! authorCollectionViewCell
            let autor = self.autoresArray[indexPath.row]
            
            
            cell.authorLabel.text = autor.nome
            let coverUrl = autor.url_imagem
            
            if AppService.util.isNotNull(coverUrl as AnyObject?) {
                AppService.util.load_image_autor(coverUrl, cod_autor: autor.cod_autor, imageview: cell.authorImg)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.topResumosCollectionView) {
            let cell = topResumosCollectionView.cellForItem(at: indexPath) as! resumoCollectionViewCell

            self.selectedResumo = self.topResumos[indexPath.row]
            performSegue(withIdentifier: "to_detail", sender: self)
        }
    }
}

extension InicioViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    //UISearchControllerDelegate
    func willDismissSearchController(_ searchController: UISearchController) {
        print("Canceled")
    }
    
    //UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search cliked")
        self.navigationItem.searchController?.dismiss(animated: true, completion: nil)
    }
    
    //UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        print("Update ME")
    }
    
    
}
