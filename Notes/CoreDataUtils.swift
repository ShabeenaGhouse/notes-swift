//
//  CoreDataUtils.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import Foundation
import CoreData

typealias FetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>
typealias ManagedObjectContext = NSManagedObjectContext

protocol ManagedObjectHoldable: class {
  var moc: NSManagedObjectContext {get}
  var backgroundMOC: NSManagedObjectContext {get}
}

extension ManagedObjectHoldable {
  var moc: NSManagedObjectContext {
    return CoreDataServices.instance.mainQueueContext
  }
  
  var backgroundMOC: NSManagedObjectContext {
    return CoreDataServices.instance.backgroundContext
  }
}

class CoreDataUtils: NSObject {
  
  static var moc: NSManagedObjectContext? {
    return CoreDataServices.instance.backgroundContext
  }
  
  static func clearDataFromCoreData(_ entity:String, moc: NSManagedObjectContext?,predicateValue: NSPredicate?) {
    
    guard let context = moc ?? moc else { return }
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    
    if let pred = predicateValue {
      request.predicate = pred
    }
    do {
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
      deleteRequest.resultType = .resultTypeObjectIDs
      guard let result = try context.execute(deleteRequest) as? NSBatchDeleteResult else {
        fatalError("Incorrect result type")
      }
      
      guard let objectIDs = result.result as? [NSManagedObjectID] else {
        fatalError("Expected NSManagedObjectIDs")
      }
      
      let changes = [NSDeletedObjectsKey: objectIDs]
      let contexts: [NSManagedObjectContext] = [CoreDataServices.instance.mainQueueContext,
                                                CoreDataServices.instance.backgroundContext]
      NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: contexts)
      
    } catch {
    }
  }
  
  static func fetchDataFromEntity(_ entityName: String, predicate: NSPredicate?,
                                  moc: NSManagedObjectContext ) -> [AnyObject] {
    // Initialize Fetch Request
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
    fetchRequest.includesPendingChanges = false
    fetchRequest.returnsObjectsAsFaults = false
    
    // Create Entity Description
    let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: moc)
    
    // Configure Fetch Request
    fetchRequest.entity = entityDescription
    
    if let pred = predicate {
      fetchRequest.predicate = pred
    }
    
    do {
      let result = try moc.fetch(fetchRequest)
      return result as [AnyObject]
    } catch let exception {
      let errorDesc = exception.localizedDescription
      print(errorDesc)
      return []
    }
  }
}
