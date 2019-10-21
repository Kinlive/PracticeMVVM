//
//  RequestTasks.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/15.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

public enum RequestTasks {
    /// A request with no additional data.
    case requestPlain
    
    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any])
    
    case requestJSONBody(parameters: [String: Any])
    
    case requestURLEncodedBody(parameters: [String: Any])
    
    case requestmultipartFormdata(parameters: [String : Any], mimeType: MimeTypes)
    
    case requestDownloadTask(download: Download<DownloadModelProtocol>, delegateTarget: URLSessionDelegate)
}
