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
    static func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return nil
        } else {
            return value
        }
    }
    
//    static func getUrl(forPlayingEpisode episodeId:NSNumber) -> URL{
//        let episodeIdString = episodeId.stringValue
//        let urlString = "https://api.spreaker.com/v2/episodes/" + episodeIdString + "/play"
//        return URL(string: urlString)!
//    }
    
    static func convertSecondsToDateString(seconds:Float64) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let date = Date(timeIntervalSince1970: seconds)
        return formatter.string(from: date)
    }
    
    static func joinAuthorsNames(authorsList: [Autor]) -> String {
        var authorsNamesList = [String]()
        for autor in authorsList {
            authorsNamesList.append(autor.nome)
        }
        return authorsNamesList.joined(separator: " & ")
    }

    
    static func joinStringWithSeparator(authorsList:  [[String : AnyObject]],separator: String) -> String{
        var authorsNamesList : [String] = []
        
        for author in authorsList {
            authorsNamesList.append(author["nome"] as! String)
        }
        return authorsNamesList.joined(separator: separator)
    }
    
//    func setupViewOnTop(bigView:UIView, subView:UIView) {
//        subView.translatesAutoresizingMaskIntoConstraints = false
//        bigView.addSubview(subView)
//        
//        //adding contrains
//        
//        //left and right margins
//        let leadingConstraint = NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
//        
//        let trailingConstraint = NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
//        
//        
//        //top
//        let topConstraint = NSLayoutConstraint(item: subView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: bigView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
//        
//        //bottom
//        if #available(iOS 11, *) {
//            let guide = bigView.safeAreaLayoutGuide
//            
//            let bottomContrain =  guide.bottomAnchor.constraint(equalTo: subView.bottomAnchor, constant: self.miniViewHeight)
//            
//            NSLayoutConstraint.activate([bottomContrain])
//            
//        } else {
//            let standardSpacing: CGFloat = 8.0
//            NSLayoutConstraint.activate([
//                subView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
//                bottomLayoutGuide.topAnchor.constraint(equalTo: subView.bottomAnchor, constant: standardSpacing)
//                ])
//        }
//        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint])
//    }

}
