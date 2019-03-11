//
//  resumo.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import RealmSwift

class ResumoEntity: Object {
    @objc dynamic var cod_resumo = ""
    @objc dynamic var titulo = ""
    @objc dynamic var subtitulo = ""
    @objc dynamic var temporada = ""
    @objc dynamic var episodio = ""
    @objc dynamic var url_imagem = ""
    @objc dynamic var url_podcast_10 = ""
    @objc dynamic var url_podcast_40_p = ""
    @objc dynamic var url_podcast_40_f = ""
    @objc dynamic var resumo_10 = ""
    let autores = RealmSwift.List<AutorEntity>()
    
    @objc dynamic var favoritado = 0
    @objc dynamic var downloaded = 0
    @objc dynamic var concluido = 0
    @objc dynamic var iniciado = 0

    
    public convenience init? (episodeDictonary: [String:AnyObject]) {
        self.init()
        guard let cod_resumo = episodeDictonary["cod_resumo"] else {
            return nil
        }
        self.cod_resumo = cod_resumo as! String
        
        guard let titulo = episodeDictonary["titulo"] else {
            return nil
        }
        self.titulo = AppService.util.populateString(titulo)
        
        guard let subtitulo = episodeDictonary["subtitulo"] else {
            return nil
        }
        self.subtitulo = AppService.util.populateString(subtitulo)
        
        guard let temporada = episodeDictonary["temporada"] else {
            return nil
        }
        self.temporada = AppService.util.populateString(temporada)

        guard let episodio = episodeDictonary["episodio"] else {
            return nil
        }
        self.episodio = AppService.util.populateString(episodio)

        guard let url_imagem = episodeDictonary["url_imagem"] else {
            return nil
        }
        self.url_imagem = AppService.util.populateString(url_imagem)
        
        guard let url_podcast_10 = episodeDictonary["url_podcast_10"] else {
            return nil
        }
        self.url_podcast_10 = AppService.util.populateString(url_podcast_10)

        guard let url_podcast_40_p = episodeDictonary["url_podcast_40_p"] else {
            return nil
        }
        self.url_podcast_40_p = AppService.util.populateString(url_podcast_40_p)

        guard let url_podcast_40_f = episodeDictonary["url_podcast_40_f"] else {
            return nil
        }
        self.url_podcast_40_f = AppService.util.populateString(url_podcast_40_f)

        guard let resumo_10 = episodeDictonary["resumo_10"] else {
            return nil
        }
        self.resumo_10 = AppService.util.populateString(resumo_10)
        
        //Autores
        guard let autores = episodeDictonary["autores"] else {
            return nil
        }
        self.autores.removeAll()
        for autorDicionary in (autores as! [[String: AnyObject]]) {
            let autorEntity = AutorEntity(autorDictonary: autorDicionary)
            self.autores.append(autorEntity!)
        }
        let valor = self.autores.count
        print(valor)
    }
    
    override static func primaryKey() -> String? {
        return "cod_resumo"
    }
}
