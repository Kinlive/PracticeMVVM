//
//  MusicHandler.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/18.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

/// A custom model conform protocol DownloadModelProtocol
struct MusicHandler: Convertible, DownloadModelProtocol {
    
    let name: String
    let artist: String
    let imageUrl: String
    let collectionName: String
    
    // protocol properties
    var url: URL
    var index: Int
    var indexPath: IndexPath
    var downloaded: Bool
    
    
    /// for multi results
    static func updateSearchResults(_ data: Data, section: Int) -> [MusicHandler]? {

        var dataDic: [String : Any] = [:]
        var errorMessage: String = ""
        var musics: [MusicHandler] = []
        
        do {
            dataDic = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
            
        } catch let parseError {
            
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return nil
        }
        
        guard let array = dataDic["results"] as? [Any] else {
            
            errorMessage += "Dictionary does not contain results key\n"
            return nil
        }
        
        var index = 0
        
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? [String : Any],
                let previewURLString = trackDictionary["previewUrl"] as? String,
                let previewURL = URL(string: previewURLString),
                let name = trackDictionary["trackName"] as? String,
                let artist = trackDictionary["artistName"] as? String,
                let imageUrl = trackDictionary["artworkUrl100"] as? String,
                let collectionName = trackDictionary["collectionName"] as? String {
                
                let indexPath = IndexPath(item: index, section: section)
                musics.append(MusicHandler(name: name,
                                         artist: artist,
                                       imageUrl: imageUrl,
                                 collectionName: collectionName,
                                            url: previewURL,
                                          index: index,
                                      indexPath: indexPath,
                                     downloaded: false))
                
                index += 1
            } else {
                errorMessage += "Problem parsing trackDictionary\n"
            }
        }
        
        return musics
        
    }
    
}
