//
//  Notes+CoreDataClass.swift
//  Notes
//
//  Created by shabeena on 22/03/21.
//
//

import Foundation
import CoreData
import UIKit

@objc(Notes)
public class Notes: NSManagedObject {
  
  static let ATTACHMENTS_PATH:String = "/attachments/"
  var FolderPath = "/notes"
  var documentsUrl: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
  
  func save(image: UIImage) -> String? {
    let fileName = "FileName"
    let fileURL = documentsUrl.appendingPathComponent(fileName)
    if let imageData = image.jpegData(compressionQuality: 1.0) {
      try? imageData.write(to: fileURL, options: .atomic)
      return fileName
    }
    return nil
  }
  
  func load(fileName: String) -> UIImage? {
    let fileURL = documentsUrl.appendingPathComponent(fileName)
    do {
      let imageData = try Data(contentsOf: fileURL)
      return UIImage(data: imageData)
    } catch {
      print("Error loading image : \(error)")
    }
    return nil
  }
  
  func buildWithDetailUsing(_ apiRecord: NotesData) {
    id = apiRecord.id
    image = apiRecord.image
    title = apiRecord.title
    notesDescription = apiRecord.body
    createdDate = apiRecord.time
  }
}
