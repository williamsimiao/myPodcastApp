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
    var episodeTitle: String?
    var author: String?
    var resumoText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        tittleLabel.text = episodeTitle
        authorLabel.text = author
        textView.text = resumoText
        textView.makeOutLine(oulineColor: .gray, foregroundColor: .white)
        textView.textAlignment = NSTextAlignment.justified
    }
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            print("FIM")
        }
    }

}
