//
//  NotesListVc.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import UIKit
import CoreData

class NotesListVc: UIViewController, ManagedObjectHoldable {
  
  @IBOutlet var notesCollectionView: UICollectionView!
  private var viewModel = NotesViewModel()
  var floatingButton: UIButton!
  private var refreshControl: UIRefreshControl!
  var colorsArray = ["#FFA78Aff", "#FFCB71ff", "#E3F18Fff", "#5BE1ECff", "#DA8DDDff", "#67CEC4ff", "#FF88B2ff"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureRefreshControl()
    constructFloatingButton()
    observeNotifications()
    configureUIListener()
    fetchNotesFromDatabase()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationItem.rightBarButtonItem?.title = ""
  }
  func setBackgroundColors(index: Int) -> UIColor {
    return UIColor(hex: colorsArray[index % colorsArray.count]) ?? .gray
  }
  
  
  private func configureRefreshControl() {
    //refresh control
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(fetchNotesFromDatabase), for: .valueChanged)
    notesCollectionView.addSubview(refreshControl)
  }
  
  @objc func fetchNotesFromDatabase() {
    viewModel.fetchNotesListFromAPI(moc: moc) { error, json in
      if let _ = json {
        DispatchQueue.main.async {
          self.notesCollectionView.reloadData()
        }
      }
    }
    refreshControl.endRefreshing()
  }
  
  private func configureUIListener() {
    viewModel.notes.bind { [weak self] (_) in
      self?.refreshControl.endRefreshing()
    }
  }
  
  private func observeNotifications() {
    let refreshNotification = Notification.Name(rawValue: Constants.CONTENT_REFRESHED)
    NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: refreshNotification, object: nil)
  }

  @objc func fetchData() {
    refreshControl.endRefreshing()
    self.viewModel.fetchNotes(moc: moc)
    self.notesCollectionView.reloadData()
  }
  
  static func storyboardInstance() -> NotesListVc {
    return NotesListVc.instantiate(fromStoryboard: .Main)
  }
  
  private func constructFloatingButton() {
    floatingButton = UIButton(type: .custom)
    floatingButton.layer.cornerRadius = 8
    floatingButton?.translatesAutoresizingMaskIntoConstraints = false
    constraintsFloatingButtonToWindow()
    floatingButton?.setImage(UIImage(named: "addButton"), for: .normal)
    floatingButton?.addTarget(self, action: #selector(navigateToDetailsSection(_:)), for: .touchUpInside)
  }
  
  private func constraintsFloatingButtonToWindow() {
    DispatchQueue.main.async {
      guard let keyWindow = self.view,
            let floatingButton = self.floatingButton else { return }
      keyWindow.addSubview(floatingButton)
      keyWindow.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
                                          constant: 20).isActive = true
      keyWindow.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
                                        constant: 20).isActive = true
      floatingButton.widthAnchor.constraint(equalToConstant:
                                              100).isActive = true
      floatingButton.heightAnchor.constraint(equalToConstant:
                                              100).isActive = true
    }
  }
  
  @objc private func navigateToDetailsSection(_ sender: Any) {
    let viewController = AddNotesVc.storyboardInstance()
    pushViewController(viewController: viewController, animated: true)
  }
}

extension NotesListVc: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfRows()
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let noteCell : NoteCollectionViewCell = notesCollectionView.dequeueReusableCell(for: indexPath)
    guard let note = viewModel.note(at: indexPath) else {
      return noteCell
    }
    let color = setBackgroundColors(index: indexPath.row)
    noteCell.configure(note: note,backgroundColor: color)
    return noteCell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let note = viewModel.note(at: indexPath) else {
      return
    }
    let vc = NotesDetailVc.instantiate(fromStoryboard: .Main)
    vc.note = note
    self.navigationController?.show(vc, sender: self)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard  let note = viewModel.note(at: indexPath) else {
      return CGSize(width: 0, height: 0)
    }
    return getCellSize(note)
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func heightForView(text:String, font: UIFont, width:CGFloat) -> CGFloat{
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
  }
  
  func getCellSize(_ note: Notes) -> CGSize {
    var height: CGFloat = 0.0
    let font = UIFont(name: "Verdana", size: 18) ?? UIFont.systemFont(ofSize: 14.0, weight: .regular)
    if let _ = note.image, let title = note.title {
      height = heightForView(text: title, font: font, width: self.notesCollectionView.frame.width)
      return CGSize(width: self.notesCollectionView.frame.width, height: height + 80)
    } else if let title = note.title {
      height = heightForView(text: title, font: font, width: (self.notesCollectionView.frame.width - 10) / 2)
      return CGSize(width: (self.notesCollectionView.frame.width - 10) / 2, height: height + 80)
    }
    return CGSize(width: 0, height: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
}
