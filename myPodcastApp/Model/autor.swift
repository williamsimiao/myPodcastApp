//
//  autorModel.swift
//  myPodcastApp
//
//  Created by William on 06/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import Foundation

class Autor {
    var cod_autor : String
    var nome : String
    var descricao : String
    var url_imagem : String
    var cod_status : String
    
    init(autorEntity: AutorEntity) {
        self.cod_autor = autorEntity.cod_autor
        self.nome = autorEntity.nome
        self.descricao = autorEntity.descricao
        self.url_imagem = autorEntity.url_imagem
        self.cod_status = autorEntity.cod_status
    }
}
