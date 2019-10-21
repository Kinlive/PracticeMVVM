//
//  Download.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/17.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

public class Download<modelT> {
    
    required init(model: modelT) {
        self.model = model
    }
    
    var model: modelT
    
    var task: URLSessionDownloadTask?
    
    var isDownloading: Bool = false
    
    var resumeData: Data?
    
    var progress: Float = 0
    
    var totalSize: String = ""
    
}

