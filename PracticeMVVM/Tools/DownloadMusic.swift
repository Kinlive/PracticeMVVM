//
//  DownloadMusic.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/18.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

enum DownloadMusic {
    case searchMusic(media: String, entity: String, term: String)
    case downloadMusic(handler: MusicHandler, delegateTarget: URLSessionDelegate)
}

extension DownloadMusic: RequestBaseType {
    var baseURL: URL {
        switch self {
        case .searchMusic:
            return URL(string: "https://itunes.apple.com/search")!
        
        case .downloadMusic(let handler, _):
            return handler.url
        }
        
    }
    
    var path: String {
        return ""
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var sampleData: Data {
        return "{}".data(using: .utf8)!
    }
    
    var task: RequestTasks {
        switch self {
        case .searchMusic(let media, let entity, let term):
            let params: [String : Any] = [
                "media" : media,
                "entity" : entity,
                "term" : term
            ]
            return .requestParameters(parameters: params)
            
        case .downloadMusic(let model, let delegateTarget):
            let download = Download<DownloadModelProtocol>(model: model)
            return .requestDownloadTask(download: download, delegateTarget: delegateTarget)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
