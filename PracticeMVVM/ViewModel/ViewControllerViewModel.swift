//
//  ViewControllerViewModel.swift
//  PracticeMVVM
//
//  Created by Thinkpower on 2019/10/21.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

class ViewControllerViewModel {
    
    // service
    private let service = RequestCommunicator<DownloadMusic>()
    
    // models
    private var musicHandlers: [MusicHandler] = []
    public private(set) var listCellViewModels: [ListCellViewModel] = []
    
    // on event input
    var searchText: String = "" {
        didSet {
            prepareRequest(with: searchText)
        }
    }
    
    // on completion outputs
    var onRequestEnd: (() -> Void)?
    
    // Methods
    private func prepareRequest(with name: String) {
        service.request(type: .searchMusic(media: "music", entity: "song", term: name)) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard let musicHandelr = MusicHandler.updateSearchResults(response.data, section: 0) else  { return }
                self?.musicHandlers.append(contentsOf: musicHandelr)
                self?.convertMusicToViewModel(musics: musicHandelr)
                
            case .failure(let error):
                print("Network error: \(error.localizedDescription)")
            }
        }
    }
    
    private func convertMusicToViewModel(musics: [MusicHandler]) {
        for music in musics {
            let listCellViewModel = ListCellViewModel(title: music.collectionName,
                                                description: music.name,
                                                   imageUrl: music.imageUrl)
            listCellViewModels.append(listCellViewModel)
        }
        onRequestEnd?()
    }
    
}
