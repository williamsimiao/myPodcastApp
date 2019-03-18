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
import Reachability

class InicioViewController: InheritanceViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var authorCollectionView: UICollectionView!
    
    @IBOutlet weak var ultimosLabel: UILabel!
    @IBOutlet weak var autoresLabel: UILabel!
    
    // MARK: - Properties
    var error_msg:String!
    var success:Bool!
    let maxResumosToShow = 5
    let maxAutoresToShow = 5
    
    var selectedResumo : Resumo?
    
    var ultimosResumosDictArray :[[String:AnyObject]]?
    var autoresDictArray :[[String:AnyObject]]?

    var topResumos = [Resumo]()
    var ultimosResumos = [Resumo]()
    var autoresArray = [Autor]()
    
    let realm = AppService.realm()
    var mySearchController: UISearchController!
    let reachability = Reachability()!

    
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

        //check Internet
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                self.makeResquest()

            }
        }
        reachability.whenUnreachable = { _ in
            self.useLocalData()
        }
        
    }
    
    func createSearchBar() {
        //Add search button on navigation
        let searchBarItem = UIBarButtonItem(image: UIImage(named: "searchWhite"),  style: .plain, target: self, action: #selector(InicioViewController.clickSearchNavItem(_:)))
        
        navigationItem.rightBarButtonItem = searchBarItem

        mySearchController = UISearchController(searchResultsController: nil)
        mySearchController.obscuresBackgroundDuringPresentation = true
        mySearchController.searchBar.tintColor = .white
        mySearchController.searchBar.placeholder = "Pesquisar"
        definesPresentationContext = true

        mySearchController.searchBar.delegate = self
        mySearchController.delegate = self
        mySearchController.searchResultsUpdater = self
        
        navigationItem.hidesSearchBarWhenScrolling = true
        self.navigationItem.searchController = mySearchController
    }
    
    @objc func clickSearchNavItem(_ sender: UIBarButtonItem) {
        
        mySearchController.searchBar.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        //if !playerManager.shared.getPlayerIsSet() {
            //self.superBottomConstraint?.constant = 0
        //}
        
        //Reachability
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Reachability notifier")
        }
        
        self.mySearchController.searchBar.text = ""
        
        self.mySearchController.dismiss(animated: false, completion: nil)
        
        self.tableView.reloadData()
        self.authorCollectionView.reloadData()
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.connection == .wifi || reachability.connection == .cellular {
            print("Conected")
        }
    }
    
    func setupUI() {
        let nibTableCell = UINib(nibName: "CustomCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")
        
        let nibAuthorCollectionCell = UINib(nibName: "authorCollectionViewCell", bundle: nil)
        authorCollectionView.register(nibAuthorCollectionCell, forCellWithReuseIdentifier: "authorCollectionCell")
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
        else if let serchResultsVC = segue.destination as? SearchResultsViewController {
            serchResultsVC.textoBusca = self.mySearchController.searchBar.text
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
        
//        cell.goBackToOriginalColors()
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
                
                NSLog("Inicio SUCCESS");
                // dados do json
                self.ultimosResumosDictArray = (json.object(forKey: "ultimos") as! Array)
                self.autoresDictArray = (json.object(forKey: "autores") as! Array)
                
            } else {
                
                NSLog("Inicio ERROR");
                error_msg = (json.value(forKey: "error") as! String)
            }
        }
        catch
        {
            print("error: sem resposta do servidor")
            useLocalData()
            return
        }
        DispatchQueue.main.async(execute: onResultReceived)
    }
    
    func onResultReceived() {
    
        if self.success {
            
            self.autoresArray = AppService.util.convertDictArrayToAutorArray(dictResumoArray: self.autoresDictArray!)

            self.ultimosResumos = AppService.util.convertDictArrayToResumoArray(dictResumoArray: self.ultimosResumosDictArray!)

            showContent()
        }
        else {
            print("onResultReceived error")
            AppService.util.alert("Erro no Inicio", message: error_msg!)
        }
        
    }
    
    func useLocalData() {
        //Resumos
        let resumoEntityList = realm.objects(ResumoEntity.self)
        var i = 0
        for resumoEntity in resumoEntityList {
            if i >= maxResumosToShow {
                break
            }
            let resumo = Resumo(resumoEntity: resumoEntity)
            self.ultimosResumos.append(resumo)
            i += 1
        }
        
        //Autors
        let autorEntityList = realm.objects(AutorEntity.self)
        i = 0
        for autorEntity in autorEntityList {
            if i >= maxAutoresToShow {
                break
            }
            let autor = Autor(autorEntity: autorEntity)
            self.autoresArray.append(autor)
            i += 1
        }
        showContent()
    }
    
    func showContent() {
        loading.isHidden = true
        loading.stopAnimating()

        self.tableView.reloadData()
        self.authorCollectionView.reloadData()
        self.ultimosLabel.isHidden = false
        self.autoresLabel.isHidden = false
    }
}

extension InicioViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.autoresArray.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.authorCollectionView.dequeueReusableCell(withReuseIdentifier: "authorCollectionCell", for: indexPath) as! authorCollectionViewCell
        let autor = self.autoresArray[indexPath.row]
        
        cell.authorLabel.text = autor.nome
        let coverUrl = autor.url_imagem
        
        if AppService.util.isNotNull(coverUrl as AnyObject?) {
            AppService.util.load_image_autor(coverUrl, cod_autor: autor.cod_autor, imageview: cell.authorImg)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView.isEqual(self.topResumosCollectionView) {
//            let cell = topResumosCollectionView.cellForItem(at: indexPath) as! resumoCollectionViewCell
//
//            self.selectedResumo = self.autoresArray[indexPath.row]
//            performSegue(withIdentifier: "to_detail", sender: self)
//        }
    }
}

extension InicioViewController: UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    //UISearchControllerDelegate
    func willDismissSearchController(_ searchController: UISearchController) {
        print("Bye")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        print("ACitive")
    }
    
    //UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Canceled")

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search cliked")
        performSegue(withIdentifier: "goto_searchResults", sender: self)

        self.navigationItem.searchController?.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
    }
    
    //UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
//        print("Update ME")
    }
    
    
}
