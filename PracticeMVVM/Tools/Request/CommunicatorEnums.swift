//
//  CommunicatorEnums.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/17.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case errorMessage(String, response: CommunicatorResponse?)
    
    init(message: String, response: CommunicatorResponse?) {
        self = .errorMessage(message, response: response)
    }
}

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}

/*
 Here are not all mime type, need found others can look up on
 https://gist.github.com/ngs/918b07f448977789cf69
 
 */
public enum MimeTypes: String {
    case html = "html"
    case css  = "css"
    case xml  = "xml"
    case gif  = "gif"
    case jpeg = "jpeg"
    case jpg  = "jpg"
    case png  = "png"
    case mp4  = "mp4"
    case txt  = "txt"
    
    var type: String {
        switch self {
        case .html: return "text/html"
        case .css:  return "text/css"
        case .xml:  return "text/xml"
        case .gif:  return "image/gif"
        case .jpeg: return "image/jpeg"
        case .jpg:  return "image/jpeg"
        case .png:  return "image/png"
        case .mp4:  return "video/mp4"
        case .txt:  return "text/plain"
            
        }
    }
    
}


