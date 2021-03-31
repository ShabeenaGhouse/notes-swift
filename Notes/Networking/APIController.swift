//
//  Result.swift
//  Notes
//
//  Created by shabeena on 22/03/21.
//

import Foundation

class APIController: NSObject {
  internal static let sharedController = APIController()
  
  func fetchNotes(callback: @escaping (Data?, URLResponse?, Error?) -> Void){
    let urlString  = "https://raw.githubusercontent.com/RishabhRaghunath/JustATest/master/posts"
    
    guard let url = URL(string: urlString) else{
      return
    }
    
    URLSession.shared.dataTask(with: url) { (data, res, err) in
      guard let data = data else {
        return
      }
      callback(data, res, err)
    }.resume()
  }
}
