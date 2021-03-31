//
//  Foundation+extensions.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import Foundation
import UIKit

extension NotificationCenter {
  func postOnMainThread(name: NSNotification.Name, object: Any?, userInfo: [AnyHashable : Any]? = nil) {
    DispatchQueue.main.async {
      self.post(name: name, object: object, userInfo: userInfo)
    }
  }
}
