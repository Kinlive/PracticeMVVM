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
