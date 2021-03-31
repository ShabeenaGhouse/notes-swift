//
//  NotesDetailVc.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import UIKit
import SwiftPhotoGallery

class NotesDetailVc: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, DetailCellDelegate {
  private var viewModel = NotesViewModel()
  @IBOutlet var noteDetailsTableView: UITableView! {
    didSet {
      noteDetailsTableView.rowHeight = UITableView.automaticDimension
    }
  }
  
  var note: Notes?
  var images = [UIImage]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
    viewModel.fetchNoteImages { notes in
      if let notes = notes {
        for note in notes {
          if let image = note.image ,let url = URL(string: image) {
            let file  = note.documentsUrl.appendingPathComponent(image)
            if FileManager.default.fileExists(atPath: file.path) {
              if let image = note.load(fileName: image) {
                self.images.append(image)
              }
            } else {
              if let data = try? Data(contentsOf: url) {
                self.images.append(UIImage(data: data)!)
              }
            }
          }
        }
      }
    }
    self.navigationController?.navigationItem.rightBarButtonItem?.title = ""
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell: NotesDetailTableViewCell = tableView.dequeueReusableCell(for: indexPath)
    guard let note = note else {
      return cell
    }
    cell.configureNoteDetails(note)
    cell.delegate = self
    cell.descriptionTextView.delegate = self
    return cell
  }
  
  func attachmentViewTapped() {
    let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
    gallery.backgroundColor = UIColor.black
    gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
    gallery.currentPageIndicatorTintColor = UIColor.white
    gallery.hidePageControl = false
    present(gallery, animated: true, completion: nil)
  }
  
  static func storyboardInstance() -> NotesDetailVc {
    return NotesDetailVc.instantiate(fromStoryboard: .Main)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}


extension NotesDetailVc: SwiftPhotoGalleryDataSource, SwiftPhotoGalleryDelegate {
  func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
    return images.count
  }
  
  func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
    return images[forIndex]
  }
  
  func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
    dismiss(animated: true, completion: nil)
  }
  
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    return true
  }
}
