//
//  Notes+CoreDataProperties.swift
//  Notes
//
//  Created by shabeena on 22/03/21.
//
//

import Foundation
import CoreData

extension Notes {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
    return NSFetchRequest<Notes>(entityName: "Notes")
  }
  @NSManaged public var createdDate: String?
  @NSManaged public var id: String?
  @NSManaged public var notesDescription: String?
  @NSManaged public var title: String?
  @NSManaged public var image: String?
}
