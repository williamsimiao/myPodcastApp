//
//  Util.swift
//  myPodcastApp
//
//  Created by William on 25/01/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import UIKit

class Util {
    func getUrl(from episodeId:String) -> URL{
        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeId + "/play"
        return URL(string: urlString)!
    }
        
}
