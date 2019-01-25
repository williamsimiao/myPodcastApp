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
    
    static func setMiniCoverImg(with imageUrl:String, theImage:UIImageView) {
        let url = URL(string:imageUrl)!
        let placeholderImage = UIImage(named: "cover_placeholder")!
        
        //        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
        //            size: self.miniCoverImg.frame.size,
        //            radius: 20.0
        //        )
        
        theImage.af_setImage(
            withURL: url,
            placeholderImage: placeholderImage        )
    }
    
    // MARK: Plist functions
    
    static func getPlist(withName name: String) -> [String]?
    {
        if  let path = Bundle.main.path(forResource: name, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String]
        }
        
        return nil
    }
    
    func write() {
        let docsBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customPlistURL = docsBaseURL.appendingPathComponent("custom.plist")
        print(customPlistURL.absoluteString)
        let dic:[String:Any] = ["key":"val"]
        // Swift Dictionary To Data.
        do  {
            let data = try PropertyListSerialization.data(fromPropertyList: dic, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
            do {
                try data.write(to: customPlistURL, options: .atomic)
                print("Successfully write")
            }catch (let err){
                print(err.localizedDescription)
            }
        }catch (let err){
            print(err.localizedDescription)
        }
    }
    
//    static func writeMyShowsToPlist(to path:String, array:[String]) {
//        let encoder = PropertyListEncoder()
//        encoder.outputFormat = .xml
//
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("ShowsIDs.plist")
//
//        do {
//            let data = try encoder.encode(preferences)
//            try data.write(to: path)
//        } catch {
//            print(error)
//        }
//    }
}
