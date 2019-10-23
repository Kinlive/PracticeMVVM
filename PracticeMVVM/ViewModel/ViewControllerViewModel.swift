//
//  ViewControllerViewModel.swift
//  PracticeMVVM
//
//  Created by Thinkpower on 2019/10/21.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

protocol ViewModelDelegate: class {
    func binding() -> ViewControllerViewModel.Events
}


class ViewControllerViewModel {
   
    struct Events {
        var onSearchMusics: Observable<String>
        var onRequestEnd: Observable<Void>
        var onRequestFail: Observable<Error>
        // maybe have more events
        // ...
    }
    
    struct Outputs {
       
        var listCellViewModels: [ListCellViewModel]
        
        // maybe have more outputs
        // ...
    }
    
    public private(set) var events: Events?
    public private(set) var outputs: Outputs?
    
    // delegate
    weak var delegate: ViewModelDelegate?
    
    // service
    private let service = RequestCommunicator<DownloadMusic>()
    
    // models
    private var musicHandlers: [MusicHandler] = []
    
    
    init(delegate: ViewModelDelegate) {
        self.delegate = delegate
        events = delegate.binding()
        outputs = Outputs(listCellViewModels: [])
        
        events?.onSearchMusics.binding(valueChanged: { [weak self] (value) in
            self?.prepareRequest(with: value ?? "")
        })
    }
    
    // Methods
    private func prepareRequest(with name: String) {
        service.request(type: .searchMusic(media: "music", entity: "song", term: name)) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let musicHandelr = MusicHandler.updateSearchResults(response.data, section: 0) else  { return }
                self?.musicHandlers.append(contentsOf: musicHandelr)
                self?.convertMusicToViewModel(musics: musicHandelr)
                
            case .failure(let error):
                self?.events?.onRequestFail.onNext(error)
               
            }
        }
    }
    
    private func convertMusicToViewModel(musics: [MusicHandler]) {
        for music in musics {
            let listCellViewModel = ListCellViewModel(title: music.collectionName,
                                                description: music.name,
                                                   imageUrl: music.imageUrl)
            
            outputs?.listCellViewModels.append(listCellViewModel)
        }
        events?.onRequestEnd.onNext()
    }
    
}
