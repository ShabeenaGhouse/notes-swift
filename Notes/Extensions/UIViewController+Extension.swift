//
//  UIViewController+Extension.swift
//  Notes
//
//  Created by shabeena on 23/03/21.
//

import Foundation
import UIKit

extension UIViewController {
  
  func dismissKeyboardAndPopViewController() {
    self.view.endEditing(true)
    self.navigationController?.popViewController(animated: true)
  }
  
  func dismissKeyboardAndPushViewController(viewController : UIViewController, animated : Bool = true) {
    self.view.endEditing(true)
    self.navigationController?.pushViewController(viewController, animated: animated)
  }
  
  func popViewController() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func pushViewController(viewController : UIViewController, animated : Bool = true) {
    self.navigationController?.pushViewController(viewController, animated: animated)
  }

  func showAlertToEnableCameraFromDeviceSettings() {
    let title = Constants.CameraPermisionAlertData.title
    let msg = Constants.CameraPermisionAlertData.message
    let alertController = UIAlertController(title: title,
                                            message: msg,
                                            preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default, handler: nil)
    alertController.addAction(cancelAction)
    
    let settingsAction = UIAlertAction(title: "Settings",
                                       style: .default) { [weak self] _ in
      Utils.openDeviceSettings()
      self?.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(settingsAction)
    
    present(alertController, animated: true)
  }
  
}
