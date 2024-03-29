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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var authorCollectionView: UICollectionView!
    
    @IBOutlet weak var ultimosLabel: UILabel!
    @IBOutlet weak var autoresLabel: UILabel!
    @IBOutlet weak var maisEpisodiosLabel: UIButton!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingMais: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    var error_msg:String!
    var success:Bool!
    
    //In case Local data is used
    let maxResumosToShow = 5
    let maxAutoresToShow = 5
    let primaryDuration = Double(0.25)
    let searchBarDefaultHeight = CGFloat(56.0)
    
    var selectedResumo : Resumo?
    var selectedAutor : Autor?
    
    var ultimosResumosDictArray :[[String:AnyObject]]?
    var autoresDictArray :[[String:AnyObject]]?
    
    var maisResumosDictArray :[[String:AnyObject]]?
    
    var topResumos = [Resumo]()
    var ultimosResumos = [Resumo]()
    var autoresArray = [Autor]()
    
    let realm = AppService.realm()
    let reachability = Reachability()!
    var isUsingLocalData = true
    var searchBarIsActive = false
    
    var page:Int = 1
    
    var pathForListViewController: String?
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.superResizableView = resizableView
        //        self.superBottomConstraint = resizableBottomConstraint
        
        slideShow.backgroundColor = .black
        slideShow.layer.cornerRadius = 10
        slideShow.clipsToBounds = true
        
        loading.isHidden = true
        loadingMais.isHidden = true
        
        
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "banner_top10_resumos")!),
            ImageSource(image: UIImage(named: "banner_top_writer")!),
            ImageSource(image: UIImage(named: "banner_indique")!)
            ])
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InicioViewController.didTapSlideShow))
        slideShow.addGestureRecognizer(gestureRecognizer)
        
        
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.init(hex: 0xFF8633) //UIColor.darkGray //
        pageIndicator.pageIndicatorTintColor = UIColor.white
        slideShow.pageIndicator = pageIndicator
        
        slideShow.circular = true
        
        slideShow.contentScaleMode = UIView.ContentMode.scaleToFill
        
        createSearchBar()
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(InicioViewController.tapView))
        viewTapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(viewTapGesture)
        
        
        setupUI()
        
        //check Internet
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi || reachability.connection == .cellular {
                self.makeResquest(path: "home.php")
                
            }
            else {
                print("neither wifi nor LTE")
            }
        }
        reachability.whenUnreachable = { _ in
            if self.isUsingLocalData {
                self.isUsingLocalData = true
                self.useLocalData()
            }
        }
    }
    
    @objc func didTapSlideShow() {
        switch slideShow.currentPage {
        case 0:
            //make request for top10
            pathForListViewController = "buscaTopResumos.php"
            performSegue(withIdentifier: "to_listResumosVC", sender: self)
            
        case 1:
            //make request for top_writer
            pathForListViewController = "buscaTopAutores.php"
            performSegue(withIdentifier: "to_listAutoresVC", sender: self)
        case 2:
            //make request for indique
            let sb = UIStoryboard(name: "Main", bundle: Bundle.main)
            let sugerirVC = sb.instantiateViewController(withIdentifier: "sugerirVC")
            sugerirVC.modalTransitionStyle = .coverVertical
            present(sugerirVC, animated: true)
            
        default:
            //make request for top10
            pathForListViewController = "buscaTopResumos.php"
            performSegue(withIdentifier: "to_listResumosVC", sender: self)
        }
        
    }
    
    func createSearchBar() {
        //Add search button on navigation
        let searchBarItem = UIBarButtonItem(image: UIImage(named: "searchWhite"),  style: .plain, target: self, action: #selector(InicioViewController.clickSearchNavItem(_:)))
        navigationItem.rightBarButtonItem = searchBarItem
    }
    
    @objc func clickSearchNavItem(_ sender: UIBarButtonItem) {
        animateSearchBar(appearing: true)
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reachability
        //        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Reachability notifier")
        }
        
        searchBar.text = ""
        
        self.searchBarHeightConstraint.constant = 0
        self.searchBarIsActive = false
        
        self.tableView.reloadData()
        self.authorCollectionView.reloadData()
        
        //to dismiss searchBar
        view.endEditing(true)
        
        
        //        self.navigationController?.navigationBar.topItem?.title = "ResumoCast"
    }
    
    func animateSearchBar(appearing: Bool) {
        if appearing {
            self.searchBar.becomeFirstResponder()
            UIView.animate(withDuration: primaryDuration, animations: {
                self.searchBarHeightConstraint.constant =  self.searchBarDefaultHeight
                self.view.layoutIfNeeded() //IMPORTANT!
                
            }) { (_) in
                self.searchBarIsActive = true
            }
        }
        else {
            UIView.animate(withDuration: primaryDuration, animations: {
                self.searchBarHeightConstraint.constant = CGFloat(0.0)
                self.view.layoutIfNeeded() //IMPORTANT!
                
            }) { (_) in
                self.searchBarIsActive = false
            }
            self.searchBar.resignFirstResponder()
        }
        
    }
    
    //    @objc func reachabilityChanged(note: Notification) {
    //
    //        let reachability = note.object as! Reachability
    //
    //        if reachability.connection == .wifi || reachability.connection == .cellular {
    //            print("Conected")
    //        }
    //    }
    
    func setupUI() {
        let nibTableCell = UINib(nibName: "InicioCell", bundle: nil)
        tableView.register(nibTableCell, forCellReuseIdentifier: "cell")
        
        let nibAuthorCollectionCell = UINib(nibName: "authorCollectionViewCell", bundle: nil)
        authorCollectionView.register(nibAuthorCollectionCell, forCellWithReuseIdentifier: "authorCollectionCell")
    }
    
    @IBAction func loadMoreEpisodios(_ sender: Any) {
        
        if !AppService.util.isConnectedToNetwork() {
            AppService.util.alert("Sem Internet", message: "Sem conexão com a internet!")
            return
        }
        
        buscarMais()
    }
    
    @objc func tapView(_ sender: Any) {
        animateSearchBar(appearing: false)
    }
    
    
}
extension InicioViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ultimosResumos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InicioCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let resumo = self.ultimosResumos[indexPath.row]
        
        let cod_resumo = resumo.cod_resumo
        
        cell.delegate = self
        cell.cod_resumo = cod_resumo
        cell.titleLabel.text = resumo.titulo
        
        let resumoEntity = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo).first
        if resumoEntity!.favoritado == 0 {
            cell.favoritoButton.setImage(UIImage(named: "favoritoWhite")!, for: .normal)
            cell.favoritoButton.tintColor = UIColor.white
        }
        else {
            cell.favoritoButton.setImage(UIImage(named: "favoritoOrange")!, for: .normal)
            cell.favoritoButton.tintColor = UIColor.init(hex: 0xFF8633)
        }
        
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
        else if let detalheVC = segue.destination as? AutorDetalheViewController {
            detalheVC.selectedAutor = self.selectedAutor
        }
        else if let serchResultsVC = segue.destination as? SearchResultsViewController {
            serchResultsVC.textoBusca = searchBar.text
        }
        else if let listResumosVC = segue.destination as? ListResumosViewController {
            listResumosVC.path = self.pathForListViewController
        }
        else if let listAutoresVC = segue.destination as? ListAutoresViewController {
            listAutoresVC.path = self.pathForListViewController
        }
        //MAIS AUTORES
//        else if let listAutoresVC = segue.destination as? ListAutoresViewController {
//            listAutoresVC.path = "buscaAutores.php"
//        }

        
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Only if the searchBar is not beeing used
        
        
        if !searchBarIsActive {
            let cell = tableView.cellForRow(at: indexPath)! as! InicioCell
            cell.setHighlightColor()
            
            self.selectedResumo = self.ultimosResumos[indexPath.row]
            
            performSegue(withIdentifier: "to_detail", sender: self)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! InicioCell
        
        //cell.setHighlightColor()
        
        //        cell.goBackToOriginalColors()
    }
    
    
}

extension InicioViewController {
    
    func makeResquest(path: String) {
        authorCollectionView.isHidden = true
        loading.isHidden = false
        loading.startAnimating()
        
        
        let link = AppConfig.urlBaseApi + path
        
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
            
            self.isUsingLocalData = false
            
            showContent()
        }
        else {
            print("onResultReceived error")
        }
        
    }
    
    func useLocalData() {
        //Resumos
        let resumoEntityList = realm.objects(ResumoEntity.self).sorted(byKeyPath: "pubDate", ascending: false)
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
        var auxAutoresArray = [Autor]()
        for autorEntity in autorEntityList {
            if i >= maxAutoresToShow {
                break
            }
            let autor = Autor(autorEntity: autorEntity)
            auxAutoresArray.append(autor)
            i += 1
        }
        self.autoresArray = auxAutoresArray
        showContent()
    }
    
    func showContent() {
        loading.isHidden = true
        authorCollectionView.isHidden = false
        loading.stopAnimating()
        
        self.tableView.reloadData()
        self.authorCollectionView.reloadData()
        self.ultimosLabel.isHidden = false
        self.autoresLabel.isHidden = false
        self.maisEpisodiosLabel.isHidden = false
    }
}

extension InicioViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.autoresArray.count
        return count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.authorCollectionView.dequeueReusableCell(withReuseIdentifier: "authorCollectionCell", for: indexPath) as! authorCollectionViewCell
        
        let itemIndex = indexPath.item
        let endIndex = self.autoresArray.count
        let outroIndex = indexPath.endIndex

        
        if itemIndex != endIndex {
            let autor = self.autoresArray[indexPath.item]
            cell.vejaMaisLabel.isHidden = true
            cell.authorLabel.text = autor.nome
            let coverUrl = autor.url_imagem
            
            if AppService.util.isNotNull(coverUrl as AnyObject?) {
                AppService.util.load_image_autor(coverUrl, cod_autor: autor.cod_autor, imageview: cell.authorImg)
            }
        }
        else {
            cell.authorImg.image = nil
            cell.authorImg.backgroundColor = ColorWeel().orangeColor
            cell.vejaMaisLabel.isHidden = false
            cell.authorLabel.isHidden = true
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
        let itemIndex = indexPath.item
        let endIndex = self.autoresArray.count

        //Go to Autor detail
        if itemIndex != endIndex {
            self.selectedAutor = autoresArray[indexPath.item]
            performSegue(withIdentifier: "to_detalhe_autor", sender: self)
        }
        //Go to list of Autor
        else {
            self.pathForListViewController = "buscaAutores.php"
            performSegue(withIdentifier: "to_listAutoresVC", sender: self)
        }
    }
}

extension InicioViewController: UISearchBarDelegate {
    
    //UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        animateSearchBar(appearing: false)
        
    }
    //SearchButton from keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        view.endEditing(true)
        performSegue(withIdentifier: "goto_searchResults", sender: self)
        
        //TODO volta contrain para 0
    }
}

extension InicioViewController: inicioCellDelegate {
    func changeFavoritoState(cod_resumo: String) {
        let resumos = realm.objects(ResumoEntity.self).filter("cod_resumo = %@", cod_resumo)
        guard let resumoEntity = resumos.first else {
            return
        }
        let resumo = Resumo(resumoEntity: resumoEntity)
        try! self.realm.write {
            if resumoEntity.favoritado == 0 {
                resumoEntity.favoritado = 1
                prepareFav(salvar: "1", cod_resumo: resumo.cod_resumo)
            } else {
                resumoEntity.favoritado = 0
                prepareFav(salvar: "0", cod_resumo: resumo.cod_resumo)
            }
            self.realm.add(resumoEntity, update: true)
        }
    }
    
}

extension InicioViewController {
    func prepareFav(salvar: String, cod_resumo: String) {
        let link = AppConfig.urlBaseApi + "salvarResumo.php"
        let url = URL(string: link)
        let keys = ["cod_usuario", "cod_resumo", "salvar"]
        
        
        let prefs:UserDefaults = UserDefaults.standard
        var cod_usuario = prefs.string(forKey: "cod_usuario")
        if cod_usuario == nil || cod_usuario == "" {
            return
        }
        
        var values = [String]()
        values.append(cod_usuario!)
        values.append(cod_resumo)
        values.append(salvar)
        makeResquestFav(url: url!, keys: keys, values: values)
    }
    
    func makeResquestFav(url: URL, keys: [String], values: [String]) {
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
            
            self.extract_json_dataFav(dataString!)
            
        })
        
        task.resume()
    }
    
    func extract_json_dataFav(_ data:NSString) {
        
        NSLog("json %@", data)
        
        let jsonData:Data = data.data(using: String.Encoding.ascii.rawValue)!
        
        
        do
        {
            // converter pra json
            let json:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
            
            
            // verificar success
            self.success = (json.value(forKey: "success") as! Bool)
            if (self.success!) {
                
                NSLog("Sucesso Fav");
            } else {
                
                NSLog("erro Fav");
                error_msg = (json.value(forKey: "error") as! String)
                
            }
        }
        catch
        {
            print("error Fav")
            return
        }
        DispatchQueue.main.async(execute: onResultReceivedFav)
        
    }
    
    func onResultReceivedFav() {
        
        
        if self.success {
            print("success na Fav")
        }
        else {
            print("Erro noa Fav")
        }
        
    }
}



// buscar mais (paginando)
extension InicioViewController {
    
    func buscarMais() {
        
        loadingMais.isHidden = false
        loadingMais.startAnimating()
        
        page = page + 1
        
        
        let post:NSString = "page=\(page)" as NSString
        
        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
        
        let postLength:NSString = String( postData.count ) as NSString
        
        
        let link = AppConfig.urlBaseApi + "maisResumos.php?"
        
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 30
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(AppConfig.authenticationKey, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            self.extract_json_mais(dataString!)
            
        })
        
        task.resume()
    }
    
    func extract_json_mais(_ data:NSString) {
        
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
                self.maisResumosDictArray = (json.object(forKey: "resumos") as! Array)
                
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
        DispatchQueue.main.async(execute: onResultMais)
    }
    
    func onResultMais() {
        
        loadingMais.isHidden = true
        loadingMais.stopAnimating()
        
        
        if self.success {
            
            var maisResumos = AppService.util.convertDictArrayToResumoArray(dictResumoArray: self.maisResumosDictArray!)
            
            for presumo in maisResumos {
                
                self.ultimosResumos.append(presumo)
            }
            
            self.tableView.reloadData()
        }
        else {
            print("onResultReceived error")
        }
        
    }
}

