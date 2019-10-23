//
//  ObservableCore.swift
//  PracticeMVVM
//
//  Created by Thinkpower on 2019/10/22.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

class Observable<T> {
    typealias ValueChanged = ((T?) -> Void)
    
    public private(set) var value: T?
    private var valueChanged: ValueChanged?
    
    init(_ value: T? = nil) {
        self.value = value
    }
    
    /// bind valueChanged event
    @discardableResult
    func binding(valueChanged: ValueChanged?) -> Self {
        self.valueChanged = valueChanged
        if let value = value {
            onNext(value)
        }
        return self
    }
    
    /// pass new value to trigger changed
    func onNext(_ value: T? = nil) {
        self.value = value
        valueChanged?(value)
    }
    
}
