//
//  ConvertableProtocol.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/24.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

protocol Convertible: Codable { }
extension Convertible {
    func convertToDic() -> [String : Any]? {
        var dic: [String : Any]?
        
        do {
            let data = try JSONEncoder().encode(self)
            dic = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : Any]
            
        } catch let error {
            printLog(logs: [error.localizedDescription], title: "convertToDic fail")
        }
        
        return dic
    }
    
    static func convertToModel(dic: [String : Any]) -> Self? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dic, options: [])
            let decoder = JSONDecoder()
            let model = try decoder.decode(Self.self, from: data)
            
            return model
            
        } catch let error {
            printLog(logs: [error.localizedDescription], title: "convertToModel fail")
            return nil
        }
    }
    
}
