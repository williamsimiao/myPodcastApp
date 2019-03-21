//
//  LeituraViewController.swift
//  myPodcastApp
//
//  Created by William on 26/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class LeituraViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    @IBOutlet weak var topMenuView: UIView!
    @IBOutlet weak var topMenuHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fontSizeSlider: CustomUISlider!
    @IBOutlet weak var tamanhoLabel: UILabel!
    
    var realm = AppService.realm()
    let positionCheckerInterval = 5.0
    
    let primaryDuration = Double(0.25)
    let maxFontSize = Float(30)
    let minFontSize = Float(10)
    let topMenuHeight = CGFloat(100)
    
    var cod_resumo:String!
    var episodeTitle: String?
    var author: String?
    var resumoText: String?
    var textSettingsButton : UIBarButtonItem?
    var lightModeButton : UIBarButtonItem?
    var darkModeButton : UIBarButtonItem?
    var starArray: [UIButton]?
    var currentResumo: Resumo?
    
    var textSettingsIsActive = false
    var lightModeIsOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        starArray = [star1, star2, star3, star4, star5]
        
        setUpNavBarMenu()
        
        scrollView.delegate = self
        tittleLabel.text = episodeTitle
        authorLabel.text = author
        
        textView.text = resumoText
        textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        textView.textAlignment = NSTextAlignment.justified
        
        
        print(textView.contentSize.height)
        
        //heightConstraint.constant = textView.contentSize.height + 300
    }
    override func viewWillAppear(_ animated: Bool) {
        resetNavBarMenu()
        //        for item in (navigationController?.navigationItem.rightBarButtonItems)! {
        //            item.tintColor = .black
        //        }
        goToCurrentProgress()
    }
    
    func setUpNavBarMenu() {
        //Hidden Menu
        topMenuView.backgroundColor = ColorWeel().darkNavBar
        
        fontSizeSlider.maximumValue = maxFontSize
        fontSizeSlider.minimumValue = minFontSize
        fontSizeSlider.value = Float((textView.font?.pointSize)!)
        
        //Navbuttons
        textSettingsButton = UIBarButtonItem(image: getOppositeColorImage(),  style: .plain, target: self, action: #selector(LeituraViewController.clickTextSettings(_:)))
        
        lightModeButton = UIBarButtonItem(image: UIImage(named: "lightMode"),  style: .plain, target: self, action: #selector(LeituraViewController.clickLightMode(_:)))
        
        darkModeButton = UIBarButtonItem(image: UIImage(named: "darkMode"),  style: .plain, target: self, action: #selector(LeituraViewController.clickDarkMode(_:)))
        
        self.navigationItem.setRightBarButtonItems([textSettingsButton!, lightModeButton!, darkModeButton!], animated: true)
        
    }
    
    func resetNavBarMenu() {
        textSettingsIsActive = false
        lightModeButton?.isHidden = true
        darkModeButton?.isHidden = true
        //TODO: Make the ajust view disapier
    }
    
    func getOppositeColorImage() -> UIImage {
        if textSettingsIsActive && lightModeIsOn {
            return UIImage(named: "textSettingsBlack")!
        }
        else if !textSettingsIsActive && lightModeIsOn {
            return UIImage(named: "textSettingsWhite")!
        }
        else if textSettingsIsActive && !lightModeIsOn {
            return UIImage(named: "textSettingsWhite")!
        }
        else if !textSettingsIsActive && !lightModeIsOn {
            return UIImage(named: "textSettingsBlack")!
        }
        
        //Redundancy
        return UIImage(named: "textSettingsWhite")!
    }
    
    @objc func clickTextSettings(_ sender: UIBarButtonItem) {
        if !textSettingsIsActive {
            textSettingsIsActive = true
            sender.image = getOppositeColorImage()
            
            lightModeButton?.isHidden = false
            darkModeButton?.isHidden = false
            
            //expanding menu
            animateTopMenuIn(presenting: true)
            
        }
        else {
            textSettingsIsActive = false
            sender.image = getOppositeColorImage()
            
            lightModeButton?.isHidden = true
            darkModeButton?.isHidden = true
            
            //retract menu
            animateTopMenuIn(presenting: false)
        }
    }
    
    @objc func clickLightMode(_ sender: UIBarButtonItem) {
        sender.tintColor = ColorWeel().orangeColor
        darkModeButton?.tintColor = .white
        //TODO: Change text and background color
    }
    
    @objc func clickDarkMode(_ sender: UIBarButtonItem) {
        sender.tintColor = ColorWeel().orangeColor
        lightModeButton?.tintColor = .white
        //TODO: Change text and background color
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio = scrollView.contentOffset.y/(scrollView.contentSize.height - scrollView.frame.size.height)
        progressView.progress = Float(ratio)
    }
    
    @IBAction func tapStar(_ sender: Any) {
        let senderStar = sender as! UIButton
        let index: Int
        switch senderStar {
        case self.star1:
            index = 1
        case self.star2:
            index = 2
        case self.star3:
            index = 3
        case self.star4:
            index = 4
        case self.star5:
            index = 5
        default:
            return
        }
        //Coloring until the taped one
        for i in 0..<index {
            let currentStar = starArray![i]
            currentStar.setImage(UIImage(named: "starBig"), for: UIControl.State.normal)
        }
        //Discoloring the others
        for i in index..<(starArray?.count)! {
            let currentStar = starArray![i]
            currentStar.setImage(UIImage(named: "starBigBlanck"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func sliderChangedValue(_ sender: Any) {
        let fontSize = fontSizeSlider.value
        textView.changeFontSize(newSize: fontSize)
    }
    
    func animateTopMenuIn(presenting: Bool) {
        UIView.animate(withDuration: primaryDuration, delay: 0.0, options: [], animations: {
            
            
            self.navigationController?.navigationBar.barTintColor = presenting ? ColorWeel().darkNavBar : .black
            self.topMenuView.isHidden = presenting ? false : true
            self.topMenuHeightConstraint.constant = presenting ? self.topMenuHeight : -self.topMenuHeight
            self.view.layoutIfNeeded() //IMPORTANT!
            
        }, completion: { (finished: Bool) in
            self.fontSizeSlider.isHidden = presenting ? false : true
            self.tamanhoLabel.isHidden = presenting ? false : true
        })
        
    }
    
    @IBAction func clickMarcarLido(_ sender: Any) {
        
        // marcar como concluido
        let resumos = self.realm.objects(ResumoEntity.self)
            .filter("cod_resumo = %@", self.cod_resumo);
        
        if let resumoEntity = resumos.first {
            
            try! self.realm.write {
                resumoEntity.concluido_resumo_10 = 1
                self.realm.add(resumoEntity, update: true)
                NSLog("concluido resumo %@", resumoEntity.cod_resumo)
            }
        }
        
        /*resumo.cod_resumo = self.cod_resumo
        concluido_resumo_10 = 1
        
        try! realm.write {
            realm.add(resumo, update: true)
            
            NSLog("concluido resumo %@", resumo.cod_resumo)
        }*/
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "BaseViewController")
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func addTimeObserverToRecordProgress(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        let timer = Timer.scheduledTimer(timeInterval: positionCheckerInterval, target: self, selector: #selector(self.recordCurrentProgress), userInfo: nil, repeats: true)
    }
    
    @objc func recordCurrentProgress(){
        let theResumo = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.currentResumo?.cod_resumo).first
        try! AppService.realm().write {
            theResumo!.progressResumo10
        }
    }
    
    func goToCurrentProgress() {
        let theResumo = self.realm.objects(ResumoEntity.self).filter("cod_resumo = %@", self.currentResumo?.cod_resumo).first

        let contentHeight = Double(self.contentView.frame.height)
        let newHeightOffset = contentHeight / (theResumo?.progressResumo10)!
        
        let xPosition = Double(self.scrollView.contentOffset.x)
        let newPoint = CGPoint(x: xPosition, y: newHeightOffset)
        self.scrollView.contentOffset = newPoint
    }
    
    
}
