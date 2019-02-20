//
//  Network.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class Network {
    
    static func setCoverImgWithPlaceHolder(imageUrl:String, theImage:UIImageView) {
        let url = URL(string:imageUrl)!
        let placeholderImage = UIImage(named: "cover_placeholder")!
        
        theImage.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage        )
    }
    
    static func getUIImageFor(imageUrl:String) -> UIImage{
        var image : UIImage?
        do {
            let url = URL(string:imageUrl)!
            let data = try Data(contentsOf: url)
            image = UIImage(data: data, scale: UIScreen.main.scale)!
        } catch {
            image = UIImage(named: "cover_placeholder")!

        }
        image!.af_inflate()
        return image!
    }
    
    static func getEpisodes() -> [[String:AnyObject]]{
        var arrEpisodes = [[String:AnyObject]]()
        //ID Resumo Cast
        let showId = "1530166"
        let episodesUrl = "https://api.spreaker.com/v2/shows/" + showId + "/episodes"
        Alamofire.request(episodesUrl).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                if let episodesData = swiftyJsonVar["response"]["items"].arrayObject {
                    arrEpisodes = episodesData as! [[String:AnyObject]]
                }
            }
        }
        return arrEpisodes
    }
}
