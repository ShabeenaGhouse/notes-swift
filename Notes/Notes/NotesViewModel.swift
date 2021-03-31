//
//  NotesViewModel.swift
//  Notes
//
//  Created by shabeena on 20/03/21.
//

import Foundation
import CoreData

final class NotesViewModel: NSObject, ManagedObjectHoldable {
  
  private let worker = NotesWorker()
  var notes: Observable<[Notes]?> = Observable(nil)
  private var fetchedResultsController = NSFetchedResultsController<Notes>()
  
  func fetchNotesListFromAPI(moc: NSManagedObjectContext, callback: @escaping (Error?, Data?) -> Void) {
    worker.fetchNotesList(moc: moc) { (error, json) in
      if let _ = json {
        let notificationName = Notification.Name( Constants.CONTENT_REFRESHED)
        NotificationCenter.default.postOnMainThread(name: notificationName,
                                                    object: nil)
        callback(error, json)
      }
    }
  }
  
  // Fetches Notes Requests from coredata
  func fetchNotes(moc: NSManagedObjectContext) {
    guard let frc = worker.makeFetchedResultsController(for: moc) else {
      notes.value = nil
      return
    }
    fetchedResultsController = frc
    fetchedResultsController.delegate = self
    performFetch()
  }
  
  func fetchNoteImages(completion: @escaping([Notes]?) -> Void) {
    let predicate = NSPredicate(format: "image != nil")
    let notes = CoreDataUtils.fetchDataFromEntity("Notes",
                                                  predicate: predicate, moc: moc) as? [Notes]
    completion(notes)
  }
  
  private func performFetch() {
    do {
      try fetchedResultsController.performFetch()
      fetchNotesUsingFRC()
    } catch {
      print("Failed to fetch notes with reason: \(error.localizedDescription)")
      notes.value = nil
    }
  }
  
  private func fetchNotesUsingFRC() {
    guard let notes = fetchedResultsController.fetchedObjects,
          !notes.isEmpty else {
      self.notes.value = nil
      return
    }
    // As values are avail, make place holder none
    self.notes.value = notes
  }
  
}
extension NotesViewModel: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    // as values are updated in core data, update view model values
    fetchNotesUsingFRC()
  }
}


extension NotesViewModel {
  
  func numberOfRows(in section: Int = 0) -> Int {
    guard let notesCount = fetchedResultsController.sections?[section].numberOfObjects else {
      return 0
    }
    return notesCount
  }
  
  func note(at indexPath: IndexPath) ->  Notes? {
    let note = fetchedResultsController.object(at: indexPath)
    return note
  }
}
