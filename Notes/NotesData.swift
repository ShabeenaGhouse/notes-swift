//
//  NotesData.swift
//  Notes
//
//  Created by shabeena on 22/03/21.
//

import Foundation

struct NotesData: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case title = "title"
    case body = "body"
    case image = "image"
    case time = "time"
  }
  var id: String?
  var title: String?
  var body: String?
  var image: String?
  var time: String?
  
}
