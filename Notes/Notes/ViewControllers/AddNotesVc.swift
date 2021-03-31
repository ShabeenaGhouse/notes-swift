//
//  AddNNotesVC.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import UIKit
import CoreData

class AddNotesVc: UITableViewController, ManagedObjectHoldable {
  
  @IBOutlet var backButton: UIButton!
  @IBOutlet var saveNoteButton: UIButton!
  @IBOutlet var addAttachmentButton: UIButton!
  @IBOutlet var titleTextView: UITextView!
  @IBOutlet var bodyTextVIew: UITextView!
  
  var selectedImage: UIImage!
  var alertActionControllers = AlertActionPickerControllers()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.setNavigationBarHidden(true, animated: true)
    alertActionControllers.delegate = self
    titleTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
    bodyTextVIew.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
  }
  
  @IBAction func backButtonPressed(_ sender: UIButton) {
    popViewController()
  }
  
  @IBAction func saveNote(_ sender: UIButton) {
    let noteEntity =  NSEntityDescription.insertNewObject(forEntityName: "Notes", into: moc)
    guard let note = noteEntity as? Notes else {
      return
    }
    note.id = UUID().uuidString
    if let photo = selectedImage {
      let imageFileName = note.save(image: photo)
      if let fname = imageFileName {
        note.image = fname
      }
    }
    note.title = titleTextView.text
    
    if let body = bodyTextVIew.text, body != Constants.BODY_TEXT {
      note.notesDescription = body
    }
    note.createdDate = String(Date().millisecondsSince1970)
    if note.title != nil || note.notesDescription != nil || note.image != nil {
      moc.saveContext()
    } else {
      showAlert()
    }
    
    self.resignFirstResponder()
    let notificationName = Notification.Name(rawValue: Constants.CONTENT_REFRESHED)
    NotificationCenter.default.postOnMainThread(name: notificationName,object: nil)
    dismissKeyboardAndPopViewController()
  }
  
  func showAlert() {
    let alert = UIAlertController(title: "Oops..", message: "Please add some text", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }
  
  @IBAction func addAttachment(_ sender: UIButton) {
    alertActionControllers.addAttachmentClicked(vc: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationItem.title = ""
  }
  
  static func storyboardInstance() -> AddNotesVc {
    return AddNotesVc.instantiate(fromStoryboard: .Main)
  }
}

extension AddNotesVc: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView == titleTextView, textView.text == Constants.TITLE_TEXT {
    textView.text = ""
    } else if textView == bodyTextVIew , textView.text == Constants.BODY_TEXT {
      textView.text = ""
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    let text = textView.text
    if !text!.isValidEntry() || text == Constants.TITLE_TEXT || text == Constants.BODY_TEXT  {
      textView.text = textView == titleTextView ? Constants.TITLE_TEXT : Constants.BODY_TEXT
    }
    textView.resignFirstResponder()
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    return true
  }
}

extension AddNotesVc: AlertActionDelegateMethods, imageAnnotationDelegate {
  
  // MARK: - AlertActionController Delegate method
  func didFinishPickingImage(image: UIImage) {
    alertActionControllers.imagePicker.dismiss(animated: true, completion: nil)
    let annotationVC = AnnotationViewController.storyboardInstance()
    annotationVC.selectedImage = image
    annotationVC.delegate = self
    pushViewController(viewController: annotationVC, animated: true)
  }
  
  // MARK: - ImageAnnotation delegate method
  func imageAnnotated(image: UIImage) {
    selectedImage = image
    addAttachmentButton.imageView?.tintColor = .green
  }
  
  @objc func tapDone(sender: Any) {
    self.view.endEditing(true)
  }
}

extension AddNotesVc {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(self.tableView, cellForRowAt: indexPath) as UITableViewCell
    return cell
  }
}
