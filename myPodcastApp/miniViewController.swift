//
//  miniViewController.swift
//  myPodcastApp
//
//  Created by William on 25/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit

class miniViewController: UIViewController {
    
    @IBOutlet weak var miniPlayButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        addShowVC()

        // Do any additional setup after loading the view.
    }
    
    func addShowVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let playingVC = storyboard.instantiateViewController(withIdentifier: "ShowsViewController") as? PlayingViewController
        self.view.addSubview((playingVC?.view)!)

        playingVC?.view.frame = CGRect(x:75, y:0, width:self.view.frame.size.width-75, height:self.view.frame.size.height)
        playingVC?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        playingVC?.didMove(toParent: self)

        
    }
    
    @IBAction func play_action(_ sender: Any) {
        print("JJ")

    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
