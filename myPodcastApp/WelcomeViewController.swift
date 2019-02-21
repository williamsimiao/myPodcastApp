//
//  WelcomeViewController.swift
//  myPodcastApp
//
//  Created by William on 21/02/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var groundButtom: UIButton!
    
    var slides:[SlideView] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        scrollView.delegate = self
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
    }
    
    func createSlides() -> [SlideView] {
        let slide1:SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide1.imageView.image = UIImage(named: "personagem1")
        slide1.descriptionLabel.text = "Boas-vindas ao Resumo Cast"
        
        let slide2:SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide2.imageView.image = UIImage(named: "personagem1")
        slide2.descriptionLabel.text = "Escute resumos incríveis de grandes livros em formatos de 40 e 10 minutos"
        
        let slide3:SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide3.imageView.image = UIImage(named: "personagem1")
        slide3.descriptionLabel.text = "Ou se preferir, você pode ler os resumos dos livros"

        let slide4:SlideView = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
        slide4.imageView.image = UIImage(named: "personagem1")
        slide4.descriptionLabel.text = "E ainda tem os nossos podcasts"

        return [slide1, slide2, slide3, slide4]
    }
    
    func setupSlideScrollView(slides : [SlideView]) {
//        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height*0.8)
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        
        scrollView.isPagingEnabled = true
        print("slides.count\(slides.count)")
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        if pageIndex == 4 {
            groundButtom.titleLabel?.text = "Então vamos lá"
        }
    }
    
    @IBAction func groundButtomAction(_ sender: Any) {
        self.performSegue(withIdentifier: "goto_main", sender: self)
    }
    

}
