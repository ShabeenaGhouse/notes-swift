//
//  Constants.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import Foundation

class Constants: NSObject {
  static let CORE_DATA_INIT = "CORE_DATA_INIT"
  static let TITLE_TEXT = "Title"
  static let BODY_TEXT = "Type Something..."
  static let CONTENT_REFRESHED = "CONTENT_REFRESHED"

  struct CameraPermisionAlertData {
    static let title = "Enable Camera Access"
    static let message = """
  Notes does not have access to your camera.
  To enable access, tap Settings and turn on Camera
  """
  }
  
}
