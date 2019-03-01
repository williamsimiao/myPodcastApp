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
    
    @IBOutlet weak var resizableView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    var currentViewController: UIViewController?
    lazy var favoritosVC: UIViewController? = {
        let favoritosVC = self.storyboard?.instantiateViewController(withIdentifier: "FavoritosViewController")
        return favoritosVC
    }()
    lazy var downloadVC : UIViewController? = {
        let downloadVC = self.storyboard?.instantiateViewController(withIdentifier: "DownloadViewController")
        
        return downloadVC
    }()
    lazy var concluidosVC : UIViewController? = {
        let concluidosVC = self.storyboard?.instantiateViewController(withIdentifier: "ConcluidosViewController")
        
        return concluidosVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        segmentControl.initUI()
        segmentControl.selectedSegmentIndex = TabIndex.favoritos.rawValue
        displayCurrentTab(TabIndex.favoritos.rawValue)

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
        }
    }

    @IBAction func switchSegment(_ sender: Any) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParent()
        
        displayCurrentTab((sender as AnyObject).selectedSegmentIndex)
        
    }
    
}
