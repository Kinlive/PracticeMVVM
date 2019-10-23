//
//  ListCellViewModel.swift
//  PracticeMVVM
//
//  Created by Thinkpower on 2019/10/22.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit


class ListCellViewModel {
    
    struct Events {
        var onImageDownloaded: Observable<UIImage>
        var onTitleChanged: Observable<String>
        var onDescriptionChanged: Observable<String>
        var onRequestFail: Observable<Error>?
    }
    
    private var musicHandler: MusicHandler
    var events: Events
    
    // operations
    private let downloadImageQueue = OperationQueue()
   
    init(_ model: MusicHandler, observerFail: Observable<Error>? = nil) {
        self.musicHandler = model
        
        events = Events(onImageDownloaded: Observable(),
                           onTitleChanged: Observable(musicHandler.collectionName),
                     onDescriptionChanged: Observable(musicHandler.name),
                            onRequestFail: observerFail)
        
        getImage(urlString: musicHandler.imageUrl)
        
    }
    
    func getImage(urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        downloadImageQueue.addOperation { [weak self] in
           do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                self?.events.onImageDownloaded.onNext(image)
            
           } catch let error {
                self?.events.onRequestFail?.onNext(error)
           }
        }
    }
    
    func clearOnReuse() {
        events.onTitleChanged.binding(valueChanged: nil)
        events.onImageDownloaded.binding(valueChanged: nil)
        events.onDescriptionChanged.binding(valueChanged: nil)
        events.onRequestFail?.binding(valueChanged: nil)
    }
    
}
