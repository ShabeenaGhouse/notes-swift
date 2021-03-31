//
//  NotesWorker.swift
//  Notes
//
//  Created by shabeena on 20/03/21.
//

import Foundation
import CoreData

class NotesWorker: ManagedObjectHoldable {
  internal static let shared = NotesWorker()

  func fetchNotesList(moc: NSManagedObjectContext, callback: @escaping (Error?, Data?) -> Void) {
    fetchNotesListFromAPI(moc: moc) { (error, json) in
      callback(error, json)
    }
  }
  
  private func fetchNotesListFromAPI(moc:NSManagedObjectContext, callback: @escaping (Error?, Data?) -> Void) {
    APIController.sharedController.fetchNotes { [weak self] (data, response, error) in
      if let data = data {
        self?.saveNotes(moc: moc, data: data)
       callback(error, data)
      }
    }
  }
  
  
  func makeFetchedResultsController(for moc: ManagedObjectContext, predicate: NSPredicate? = nil) -> NSFetchedResultsController<Notes>? {
    let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
    fetchRequest.predicate = predicate
    let createdDateKey = #keyPath(Notes.createdDate)
    let createdDateSort = NSSortDescriptor(key: createdDateKey,
                                           ascending: false)
    fetchRequest.sortDescriptors = [createdDateSort]
    fetchRequest.returnsObjectsAsFaults = false
    fetchRequest.includesPendingChanges = false
    let fetchedResults = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: moc,
                                                    sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResults
  }

  private func saveNotes(moc: NSManagedObjectContext, data: Data) {
    let decoder = JSONDecoder()
    do {
      let notesRoot: [NotesData] = try decoder.decode([NotesData].self, from: data)
      moc.perform { [weak self] in
        self?.insertOrUpdateNotes(notesRoot, in: moc, withDetails: true)
        moc.saveContext()
      }
    } catch {
      print("Exception @ decoding note mock records: \(error.localizedDescription)")
    }
  }
  
  func insertOrUpdateNotes(_ apiRecords: [NotesData]?,
                           in moc: ManagedObjectContext,
                           withDetails: Bool = false) {
    guard let apiRecords = apiRecords else {
      return
    }
    for apiRecord in apiRecords {
      var existingNote : Notes
      let predicate = NSPredicate(format: "id == %@", apiRecord.id ?? "")
      // get the record from DB if avail
      if let note = CoreDataUtils.fetchDataFromEntity("Notes", predicate:predicate, moc: moc).first as? Notes {
        existingNote = note
      } else {
        // if not avail in DB, create a new one
        existingNote = Notes(context: moc)
      }
      // build the record
      if !withDetails {
        existingNote.buildWithDetailUsing(apiRecord)
      } else {
        // It saves the details of Notes
        existingNote.buildWithDetailUsing(apiRecord)
      }
    }
  }
}
