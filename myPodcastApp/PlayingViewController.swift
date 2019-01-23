//
//  PlayingViewController.swift
//  myPodcastApp
//
//  Created by William on 22/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import AlamofireImage

class PlayingViewController: UIViewController {
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var coverImg: UIImageView!
    var imageUrl = String()
    var player:AVPlayer?
    let valor = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(imageUrl).responseImage { (response) in
            print(response)
            if let image = response.result.value {
                DispatchQueue.main.async {
                    self.coverImg.image = image
                }
            }
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func back_action(_ sender: Any) {
        playerManager.shared.rewind()
    }
    
    @IBAction func play_action(_ sender: Any) {
        playerManager.shared.play()
    }
    
    @IBAction func foward_action(_ sender: Any) {
        playerManager.shared.foward()
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
