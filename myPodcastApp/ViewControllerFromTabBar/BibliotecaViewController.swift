//
//  BibliotecaViewController.swift
//  myPodcastApp
//
//  Created by William on 04/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class BibliotecaViewController: InheritanceViewController {
    
    @IBOutlet weak var resizableView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    enum TabIndex : Int {
        case favoritos = 0
        case downloads = 1
        case concluidos = 2
    }
    
    var episodesArray :[[String:AnyObject]]?
    var error_msg : String?
    var success : Bool?
    
    
    var size = CGSize(width: 2, height: 29)
    var lineWidth: CGFloat = 2
    
    var currentViewController: UIViewController?
    
    lazy var favoritosVC: FavoritosViewController? = {
        let favoritosVC = self.storyboard?.instantiateViewController(withIdentifier: "FavoritosViewController")
        return favoritosVC as? FavoritosViewController
    }()
    
    lazy var downloadVC : DownloadViewController? = {
        let downloadVC = self.storyboard?.instantiateViewController(withIdentifier: "DownloadViewController")
        
        return downloadVC as? DownloadViewController
    }()
    
    lazy var concluidosVC : ConcluidosViewController? = {
        let concluidosVC = self.storyboard?.instantiateViewController(withIdentifier: "ConcluidosViewController")
        
        return concluidosVC as? ConcluidosViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = TabIndex.favoritos.rawValue
        displayCurrentTab(TabIndex.favoritos.rawValue)
        
        segmentControl.replaceSegments(segments: ["Salvos", "Baixados", "Concluídos"])
        
        segmentControl.setBackgroundImage(background(color: .black), for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
        
        segmentControl.setDividerImage(divider(leftColor: ColorWeel().orangeColor, rightColor: .black), forLeftSegmentState: UIControl.State.normal, rightSegmentState: UIControl.State.normal, barMetrics: UIBarMetrics.default)
        
        segmentControl.selectedSegmentIndex = 0
        
        
        self.favoritosVC?.tableView.reloadData()
    }
    
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        
        var vc: UIViewController?
        
        switch index {
            case TabIndex.favoritos.rawValue :
                vc = favoritosVC
                break
            
            case TabIndex.downloads.rawValue :
                vc = downloadVC
                break
            
            case TabIndex.concluidos.rawValue :
                vc = concluidosVC
                break
            
            default:
                return nil
        }
        
        return vc
    }
    
    func displayCurrentTab(_ tabIndex: Int) {
        
        print("displayCurrentTab")
        
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChild(vc)
            vc.didMove(toParent: self)
            
            vc.view.frame = self.contentView.bounds
            self.contentView.addSubview(vc.view)
            self.currentViewController = vc
            
            switch tabIndex {
                case TabIndex.favoritos.rawValue :
                    self.favoritosVC?.tableView.reloadData()
                    break
                
                case TabIndex.downloads.rawValue :
                    self.downloadVC?.tableView.reloadData()
                    break
                
                case TabIndex.concluidos.rawValue :
                    self.concluidosVC?.tableView.reloadData()
                    break
                
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
