//
//  RequestResponse.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/17.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

struct CommunicatorResponse {
    
    let statusCode: Int
    
    let data: Data
    
    let request: URLRequest?
    
    let response: HTTPURLResponse?
    
    init(statusCode: Int, data: Data, request: URLRequest? = nil, response: HTTPURLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }
}
