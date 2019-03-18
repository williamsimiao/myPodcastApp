//
//  AppService.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

public struct AppService {
    static let server   = AppServer()
    //static let user     = AppUser()
    static let util     = AppUtil()
    //static let template = AppTemplate()
    
    static func realm() -> Realm {
        print("REALM CONFIG: \(Realm.Configuration.defaultConfiguration.fileURL)")
        let config = Realm.Configuration(schemaVersion: 12)
        let realm = try! Realm(configuration: config)
        return realm
    }
}
