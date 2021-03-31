//
//  UIKit+Extensions.swift
//  Notes
//
//  Created by shabeena on 23/03/21.
//

import Foundation
import UIKit

extension Date {
  var millisecondsSince1970:Int64 {
    return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }
  
  init(milliseconds:Int64) {
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
  }
}

extension String {
  func isValidEntry() -> Bool {
    return !self.trim().isEmpty
  }
  
  func trim() -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

extension UIImageView {
  func load(url: URL) {
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url) {
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            self?.image = image
          }
        }
      }
    }
  }
}

extension UITextView {
  func addDoneButton(title: String, target: Any, selector: Selector) {
    let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                          y: 0.0,
                                          width: UIScreen.main.bounds.size.width,
                                          height: 44.0))
    let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: nil, action: nil)
    let barButton = UIBarButtonItem(title: title, style: .plain,
                                    target: target, action: selector)
    toolBar.setItems([flexible, barButton], animated: false)
    self.inputAccessoryView = toolBar
  }
  
  func addPlaceHolderColorForDetailTextView() {
    self.textColor = UIColor.lightGray
  }
  
  func addHyperLinksToText(originalText: String, hyperLinks: [String: String]) -> NSAttributedString {
    let style = NSMutableParagraphStyle()
    style.alignment = .left
    let attributedOriginalText = NSMutableAttributedString(string: originalText)
    for (hyperLink, urlString) in hyperLinks {
      //clickhere
      let url = urlString.dropLast();
      let linkRange = attributedOriginalText.mutableString.range(of: hyperLink)
      let fullRange = NSRange(location: 0, length: attributedOriginalText.length)
      let urlRange =             attributedOriginalText.mutableString.range(of: urlString)
      
      attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: url, range: linkRange)
      
      attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
      attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: fullRange)
      attributedOriginalText.deleteCharacters(in: NSRange(location: linkRange.location, length: 1))
      attributedOriginalText.deleteCharacters(in: NSRange(location: urlRange.location-3, length: urlRange.length+2))
    }
    
    self.linkTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.systemBlue
    ]
    self.attributedText = attributedOriginalText
    return attributedText
  }
}

extension NSMutableAttributedString {
  var fontSize:CGFloat { return 22 }
  var boldFont:UIFont { return UIFont(name: "Verdana - bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
  
  func highlightTarget(_ target: String, color: UIColor) -> NSMutableAttributedString {
    let regPattern = "\\*{2}(.*?)\\*{2}"
    
    if let regex = try? NSRegularExpression(pattern: regPattern, options: []) {
      
      let matchesArray = regex.matches(in: target, options: [], range: NSRange(location: 0, length: target.count))
      
      //iterate through matched text
      for match in matchesArray {
        let matchRange = match.range(at: 0)
        
        //Find start and end position
        let startRange = target.index(target.startIndex, offsetBy: matchRange.location)
        let endRange = target.index(target.startIndex, offsetBy: (matchRange.location + matchRange.length))
        
        let actualRange = startRange..<endRange
        
        let mySubstring = String(target[actualRange])
        let attributedText = NSMutableAttributedString(string: mySubstring)
        
        //Add Attributes
        let boldAttributes = [NSAttributedString.Key.font: boldFont]
        let colorAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let convertedRange = NSRange(actualRange, in: target)
        let innerRange = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttributes(boldAttributes, range: innerRange)
        attributedText.addAttributes(colorAttributes, range: innerRange)
        attributedText.deleteCharacters(in: NSRange(location: 0 , length: 2))
        attributedText.deleteCharacters(in: NSRange(location: (matchRange.length-4) , length: 2))
        self.replaceCharacters(in: convertedRange, with: attributedText)
      }
    }
    return self
  }
}

extension UIColor {
  public convenience init?(hex: String) {
    let r, g, b, a: CGFloat
    
    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])
      
      if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
          a = CGFloat(hexNumber & 0x000000ff) / 255
          
          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }
    return nil
  }
}
