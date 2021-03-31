//
//  Utility.swift
//  Notes
//
//  Created by shabeena on 22/03/21.
//

import Foundation
import UIKit
class Utils: NSObject {
  
  func getDate(dateString: String) -> Date? {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      dateFormatter.timeZone = TimeZone.current
      dateFormatter.locale = Locale.current
      return dateFormatter.date(from: dateString) // replace Date String
  }
  
  static func toDate(_ dateString: String?) -> Date? {
    if dateString == nil {
      return nil
    }
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar.current
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
    let date = dateFormatter.date(from: dateString!)
    return date
  }
  
  static func toDateString(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "MMM dd,yyyy"
    return dateFormatter.string(from: date)
  }
  
  static func openDeviceSettings() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl, completionHandler: { _ in})
    }
  }
}
