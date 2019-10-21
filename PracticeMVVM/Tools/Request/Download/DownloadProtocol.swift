//
//  DownloadProtocol.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/17.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

public protocol DownloadModelProtocol {
    
    var url: URL { get set }
    var index: Int { get set }
    var indexPath: IndexPath { get set }
    var downloaded: Bool { get set }
}
