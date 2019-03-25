//
//  AppError.swift
//  morumbicupons
//
//  Created by Cristiano Silva on 22/08/2018.
//  Copyright © 2018 Dubba Tecnologia. All rights reserved.
//

enum AppError: Error {
    case cryptError
    case networkError
    case discoverydError
    //playerManagerErrors
    case urlError
    case urlKeyError
    //
    case filePathError
    case dictionaryIncomplete
    //
    case noRealmResult
}
