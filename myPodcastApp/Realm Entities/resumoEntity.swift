//
//  resumo.swift
//  myPodcastApp
//
//  Created by William on 01/03/19.
//  Copyright © 2019 William. All rights reserved.
//

import RealmSwift
import MediaPlayer

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
    @objc dynamic var descricao = ""

    let autores = RealmSwift.List<AutorEntity>()
    
    @objc dynamic var favoritado = 0
    @objc dynamic var downloaded = 0
    
    //Concluido field suits both free and premium types
    @objc dynamic var concluido_podcast_40 = 0
    @objc dynamic var concluido_podcast_10 = 0
    @objc dynamic var concluido_resumo_10 = 0
    
    //Seconds
    @objc dynamic var progressPodcast_10 = 0.0
    @objc dynamic var progressPodcast_40_p = 0.0
    @objc dynamic var progressPodcast_40_f = 0.0
    
    //0 to 1
    @objc dynamic var progressResumo10 = 0.0
    
    @objc dynamic var preferedSpeed = 1.0
    
    public convenience init? (episodeDictonary: [String:AnyObject]) {
        self.init()
        do {
            try update(episodeDictonary: episodeDictonary)
        }
        catch AppError.dictionaryIncomplete {
            
        } catch {
            print(error)
        }
    }
    
    func update(episodeDictonary: [String:AnyObject]) throws {
        let my_cod_resumo = episodeDictonary["cod_resumo"] as! String
        if self.cod_resumo != ""  && my_cod_resumo != self.cod_resumo {
            return
        }
        
        //Autores
        guard let autores = episodeDictonary["autores"] else {
            throw AppError.dictionaryIncomplete
        }
        self.autores.removeAll()
        for autorDicionary in (autores as! [[String: AnyObject]]) {
            let my_cod_autor = autorDicionary["cod_autor"] as! String
            var autorEntity = AppService.realm().objects(AutorEntity.self).filter("cod_autor = %@", my_cod_autor).first
            if autorEntity?.cod_autor != my_cod_autor {
                autorEntity = AutorEntity(autorDictonary: autorDicionary)
            }
            self.autores.append(autorEntity!)
        }

        try! AppService.realm().write {
            guard let titulo = episodeDictonary["titulo"] else {
                throw AppError.dictionaryIncomplete
            }
            self.titulo = AppService.util.populateString(titulo)

            guard let subtitulo = episodeDictonary["subtitulo"] else {
                throw AppError.dictionaryIncomplete
            }
            self.subtitulo = AppService.util.populateString(subtitulo)

            guard let temporada = episodeDictonary["temporada"] else {
                throw AppError.dictionaryIncomplete
            }
            self.temporada = AppService.util.populateString(temporada)

            guard let episodio = episodeDictonary["episodio"] else {
                throw AppError.dictionaryIncomplete
            }
            self.episodio = AppService.util.populateString(episodio)

            guard let url_imagem = episodeDictonary["url_imagem"] else {
                throw AppError.dictionaryIncomplete
            }
            self.url_imagem = AppService.util.populateString(url_imagem)

            guard let url_podcast_10 = episodeDictonary["url_podcast_10"] else {
                throw AppError.dictionaryIncomplete
            }
            self.url_podcast_10 = AppService.util.populateString(url_podcast_10)

            guard let url_podcast_40_p = episodeDictonary["url_podcast_40_p"] else {
                throw AppError.dictionaryIncomplete
            }
            self.url_podcast_40_p = AppService.util.populateString(url_podcast_40_p)

            guard let url_podcast_40_f = episodeDictonary["url_podcast_40_f"] else {
                throw AppError.dictionaryIncomplete
            }
            self.url_podcast_40_f = AppService.util.populateString(url_podcast_40_f)

            guard let resumo_10 = episodeDictonary["resumo_10"] else {
                throw AppError.dictionaryIncomplete
            }
            self.resumo_10 = AppService.util.populateString(resumo_10)

            AppService.realm().add(self, update: true)
        }
    }
    
    func addDescription(episodeDetailedDictonary: [String:AnyObject]) -> ResumoEntity {
        if let theDescricao = episodeDetailedDictonary["subtitulo"] {
            try! AppService.realm().write {
                self.descricao = AppService.util.populateString(theDescricao)
                AppService.realm().add(self, update: true)
            }
        }
        return self
    }
        
    override static func primaryKey() -> String? {
        return "cod_resumo"
    }
}
