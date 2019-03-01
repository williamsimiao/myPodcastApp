//
//  BibliotecaViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class BibliotecaViewController: InheritanceViewController {
    
    enum TabIndex : Int {
        case favoritos = 0
        case downloads = 1
        case concluidos = 2
    }
    
    var episodesArray :[[String:AnyObject]]?
    var error_msg : String?
    var success : Bool?


    
    @IBOutlet weak var resizableView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    

    
    var size = CGSize(width: 2, height: 29)
    var lineWidth: CGFloat = 2

    var currentViewController: UIViewController?
    lazy var favoritosVC: FavoritosViewController? = {
        let favoritosVC = self.storyboard?.instantiateViewController(withIdentifier: "FavoritosViewController")
        return favoritosVC as! FavoritosViewController
    }()
    lazy var downloadVC : DownloadViewController? = {
        let downloadVC = self.storyboard?.instantiateViewController(withIdentifier: "DownloadViewController")
        
        return downloadVC as! DownloadViewController
    }()
    lazy var concluidosVC : ConcluidosViewController? = {
        let concluidosVC = self.storyboard?.instantiateViewController(withIdentifier: "ConcluidosViewController")
        
        return concluidosVC as! ConcluidosViewController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentControl.selectedSegmentIndex = TabIndex.favoritos.rawValue
        displayCurrentTab(TabIndex.favoritos.rawValue)
        
        segmentControl.replaceSegments(segments: ["Favoritos", "Downloads", "Concluídos"])
        
        segmentControl.setBackgroundImage(background(color: .black), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
        
        segmentControl.setDividerImage(divider(leftColor: ColorWeel().orangeColor, rightColor: .black), forLeftSegmentState: UIControl.State.normal, rightSegmentState: UIControl.State.normal, barMetrics: UIBarMetrics.default)
        
        segmentControl.selectedSegmentIndex = 0
        
        makeResquest()
        
    }

    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.favoritos.rawValue :
            vc = favoritosVC

        case TabIndex.downloads.rawValue :
            vc = downloadVC

        case TabIndex.concluidos.rawValue :
            vc = concluidosVC


        default:
            return nil
        }
        
        return vc
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
            
            switch tabIndex {
            case TabIndex.favoritos.rawValue :
                self.favoritosVC?.episodesArray = self.episodesArray
                self.favoritosVC?.tableView.reloadData()
                
            case TabIndex.downloads.rawValue :
                self.downloadVC?.episodesArray = self.episodesArray
                self.downloadVC?.tableView.reloadData()
                
            case TabIndex.concluidos.rawValue :
                self.concluidosVC?.episodesArray = self.episodesArray
                self.concluidosVC?.tableView.reloadData()
                
                
            default:
                return
            }
            
        }
    }

    @IBAction func switchSegment(_ sender: Any) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParent()
        
        displayCurrentTab((sender as AnyObject).selectedSegmentIndex)
        
    }
    
    func background(color: UIColor) -> UIImage? {
        return UIImage.render(size: size) {
            color.setFill()
            UIRectFill(CGRect(x: 0, y: size.height-lineWidth, width: size.width, height: lineWidth))
        }
    }
    
    func divider(leftColor: UIColor, rightColor: UIColor) -> UIImage? {
        return UIImage.render(size: size) {
            UIColor.clear.setFill()
        }
    }
    
}

extension BibliotecaViewController {
    func makeResquest() {
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
        
        if self.success! {
            //Salvar
            
            self.favoritosVC?.episodesArray = self.episodesArray
            self.favoritosVC?.tableView.reloadData()

            //            AppService.util.alert("deu bom", message: "Obaaa" as! String)
            
        }
        else {
            AppService.util.alert("Erro no Login", message: error_msg!)
        }
    }
}
