//
//  CoreDataServices.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import Foundation
import CoreData

class CoreDataServices {
  static var instance: CoreDataServices = CoreDataServices()
  var persistentContainer: NSPersistentContainer
  var mainQueueContext: NSManagedObjectContext!
  var backgroundContext: NSManagedObjectContext!
  
  private init() {
    self.persistentContainer = NSPersistentContainer(name: "Notes")
    persistentContainer.loadPersistentStores { [weak self] (_, error) in
      
      guard let weakSelf = self else {
        return
      }
      
      if let error = error {
        fatalError("Unable to load persistent stores \(error)")
      }
      
      weakSelf.setupContexts()
      let notificationName = NSNotification.Name(rawValue: Constants.CORE_DATA_INIT)
      NotificationCenter.default.postOnMainThread(name: notificationName, object: nil)
    }
  }
  
  private func setupContexts() {
    createContexts()
    registerForSaveNotifications()
  }
  
  private func createContexts() {
    mainQueueContext = persistentContainer.viewContext
    backgroundContext = persistentContainer.newBackgroundContext()
    
    // Added this to resolve the delay in updating changes from background thread to main thread
    mainQueueContext.stalenessInterval = 0
    backgroundContext.stalenessInterval = 0
    
    [mainQueueContext, backgroundContext].forEach { (context) in
      context?.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
  }
  
  private func registerForSaveNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.mainContextDidSave(_:)),
      name: NSNotification.Name.NSManagedObjectContextDidSave,
      object: mainQueueContext
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.backgroundContextDidSave(_:)),
      name: NSNotification.Name.NSManagedObjectContextDidSave,
      object: backgroundContext
    )
  }
  
  @objc func mainContextDidSave(_ note: Notification) {
    backgroundContext.performMergeChanges(from: note)
  }
  
  @objc func backgroundContextDidSave(_ note: Notification) {
    mainQueueContext.performMergeChanges(from: note)
  }
}

public extension NSManagedObjectContext {
  
  func saveContext() {
    do {
      if hasChanges {
        try save()
      }
    } catch let error {
      print(error)
    }
  }
}

extension NSManagedObjectContext {
  func performMergeChanges(from note: Notification) {
    perform {
      self.mergeChanges(fromContextDidSave: note)
    }
  }
  
  func fetchObject<T: NSManagedObject>(with id: NSManagedObjectID, ofType: T.Type) -> T {
    return self.object(with: id) as! T
  }
  
  func fetchObjectInContext<T: NSManagedObject>(_ object: T) -> T {
    return self.object(with: object.objectID) as! T
  }
}
