//
//  Extension+UIViewController.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/9.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func convienceAlert(alert: String?, alertMessage: String?, actions: [String], completion: (() -> Void)?, actionCompletion: ((UIAlertAction) -> Void)?) {
        
        let alert = UIAlertController(title: alert, message: alertMessage, preferredStyle: .alert)
        for actionMessage in actions {
            let action = UIAlertAction(title: actionMessage, style: .default, handler: actionCompletion)
            alert.addAction(action)
        }
        present(alert, animated: true, completion: completion)
    }
    
    func openSetting() {
        guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingUrl) {
            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
        }
    }
}

extension NSObject {
    func setAssociated<T>(value: T, associatedKey: UnsafeRawPointer, policy: objc_AssociationPolicy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC) -> Void {
        objc_setAssociatedObject(self, associatedKey, value, policy)
    }
    
    func getAssociated<T>(associatedKey: UnsafeRawPointer) -> T? {
        let value = objc_getAssociatedObject(self, associatedKey) as? T
        return value;
    }
}

extension UISearchBar {
    
    struct AssociatedKeys {
        static var text = "BindText"
    }
    
    var bindText: Observable<String>? {
        if let observeText = objc_getAssociatedObject(self, &AssociatedKeys.text) as? Observable<String> {
            
            return observeText
        } else {
            let b = Observable<String>(self.text)
            objc_setAssociatedObject(self, &AssociatedKeys.text, b, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }
    
}


extension UIView {
    struct AssociatedKeys {
        static var isHidden = "isHidden"
        
    }
    
    var bindIsHidden: Observable<Bool> {
        if let oldValue = objc_getAssociatedObject(self, &AssociatedKeys.isHidden) as? Observable<Bool> {
            return oldValue
            
        } else {
            let newValue = Observable<Bool>(self.isHidden)
            objc_setAssociatedObject(self, &AssociatedKeys.isHidden, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newValue
        }
        
    }
}
