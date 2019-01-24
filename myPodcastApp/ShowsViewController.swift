//
//  ShowsViewController.swift
//  myPodcastApp
//
//  Created by William on 24/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ShowsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let arrShowsId = ["2885428", "1503678", "1530166", "1615101", "1534748"]
    var arrShows = [[String:AnyObject]]()
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for showId in arrShowsId {
            let showUrl = "https://api.spreaker.com/v2/shows/" + showId
            Alamofire.request(showUrl).responseJSON { (responseData) in
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let showData = swiftyJsonVar["response"]["show"].dictionaryObject {
                    self.arrShows.append(showData as [String : AnyObject])
                }
                if self.arrShows.count > 0 {
                    self.CollectionView.reloadData()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! ShowCollectionCell
        
        cell.backgroundColor = .gray
        let url = URL(string:self.arrShows[indexPath.row]["image_url"] as! String)!
        let placeholderImage = UIImage(named: "cover_placeholder")!
        cell.coverImg.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage
        )
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let episodesVC = segue.destination as! EpisodesViewController
        if let indexPath = CollectionView.indexPathsForSelectedItems?.first {
            episodesVC.dictShow = self.arrShows[indexPath.row]
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toEpisodeVC", sender: self)
        
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
