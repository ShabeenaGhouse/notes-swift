//
//  AppStoryBoard.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import Foundation
import UIKit

enum AppStoryboard: String {
  case Main
  case Annotation
}

// MARK: - Initializers

extension AppStoryboard {
  var instance : UIStoryboard {
    return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
  }
  
  func viewController<T : UIViewController>(viewControllerClass : T.Type,
                                            function : String = #function,
                                            line : Int = #line,
                                            file : String = #file) -> T {
    
    let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
    
    guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
      var errorMsg = "ViewController with identifier \(storyboardID), "
      errorMsg.append("not found in \(self.rawValue) Storyboard.\n")
      errorMsg.append("File : \(file) \n")
      errorMsg.append("Line Number : \(line) \n")
      errorMsg.append("Function : \(function)")
      fatalError(errorMsg)
    }
    
    return scene
  }
  
  func initialViewController() -> UIViewController? {
    return instance.instantiateInitialViewController()
  }
}

// MARK: - UIViewController Extensions

extension UIViewController {
  
  class var storyboardID : String {
    return "\(self)"
  }
  
  static func instantiate(fromStoryboard storyboard: AppStoryboard) -> Self {
    return storyboard.viewController(viewControllerClass: self)
  }
}

