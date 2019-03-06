//
//  autor.swift
//  myPodcastApp
//
//  Created by William on 05/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation
import RealmSwift

class Autor: Object {
    @objc dynamic var cod_autor = ""
    @objc dynamic var nome = ""
    @objc dynamic var descricao = ""
    @objc dynamic var url_imagem = ""
    @objc dynamic var cod_status = ""
    
    public convenience init? (autorDictonary: [String:AnyObject]) {
        self.init()
        guard let cod_autor = autorDictonary["cod_autor"] else {
            return
        }
        self.cod_autor = cod_autor as! String
        
        guard let nome = autorDictonary["nome"] else {
            return
        }
        self.nome = nome as! String

        guard let descricao = autorDictonary["descricao"] else {
            return
        }
        self.descricao = descricao as! String

        guard let url_imagem = autorDictonary["url_imagem"] else {
            return
        }
        self.url_imagem = url_imagem as! String
        

        guard let cod_status = autorDictonary["cod_status"] else {
            return
        }
        self.cod_status = cod_status as! String
    }

}

