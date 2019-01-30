//
//  Network.swift
//  myPodcastApp
//
//  Created by William on 30/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import UIKit

class Network {
    
    static func setCoverImgWithPlaceHolder(imageUrl:String, theImage:UIImageView) {
        let url = URL(string:imageUrl)!
        let placeholderImage = UIImage(named: "cover_placeholder")!
        
        theImage.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage        )
    }
}
