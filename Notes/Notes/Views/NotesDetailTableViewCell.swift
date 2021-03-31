//
//  NotesDetailTableViewCell.swift
//  Notes
//
//  Created by shabeena on 23/03/21.
//

import UIKit

protocol DetailCellDelegate: class {
  func attachmentViewTapped()
}

class NotesDetailTableViewCell: UITableViewCell {
  
  @IBOutlet var attachmentView: UIView!
  @IBOutlet var thumbnail: UIImageView!
  @IBOutlet var detailsView: UIView!
  @IBOutlet var titleTextView: UITextView!
  @IBOutlet var descriptionTextView: UITextView!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var titleViewheightConstraint: NSLayoutConstraint!
  weak var delegate: DetailCellDelegate!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func configureNoteDetails(_ note: Notes) {
    if let image = note.image, let url = URL(string: image) {
      let file  = note.documentsUrl.appendingPathComponent(image)
      if FileManager.default.fileExists(atPath: file.path) {
        let image = note.load(fileName: image)
        thumbnail.image = image
      } else {
        thumbnail.load(url: url)
      }
    } else  {
      attachmentView.isHidden = true
    }
    
    if let dateString = note.createdDate {
      let date = Date(timeIntervalSince1970: (Double(dateString) ?? 00/1000.0))
      dateLabel.text = Utils.toDateString(date)
    }
    if let title = note.title {
      titleTextView.text = title
    }
    if let body = note.notesDescription {
      descriptionTextView.text = body
    }
    let imagetapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
    attachmentView.addGestureRecognizer(imagetapGesture)
    
    if let desc = note.notesDescription {
      let pattern = "\\[(.*?)\\]\\((.*?)\\)"
      let regex = try! NSRegularExpression(pattern: pattern)
      let results = regex.matches(in:desc, range:NSMakeRange(0, desc.utf16.count))
      for match in results {
        let third = match.range(at: 0)
        
        let start = desc.index(desc.startIndex, offsetBy: third.location)
        let end = desc.index(desc.startIndex, offsetBy: (third.location + third.length))
        let range = start..<end
        
        let mySubstring = String(desc[range])
        
        let linkArr = mySubstring.components(separatedBy: "](")
        
        
        let chunks = stride(from: 0, to: linkArr.count, by: 2).map {
          Array(linkArr[$0..<min($0 + 2, linkArr.count)])
        }
        for chunk in chunks {
          _ = descriptionTextView.addHyperLinksToText(originalText: desc, hyperLinks: [chunk.first ?? ""  : chunk.last ?? ""])
        }
      }
      let attributedstr = descriptionTextView.attributedText
      let muta = NSMutableAttributedString(attributedString: attributedstr!)
      let result12 = muta.highlightTarget(descriptionTextView.text, color: .white)
      
      descriptionTextView.attributedText = result12
    }
  }
  
  @objc func imageTapped(gesture: UITapGestureRecognizer) {
    delegate.attachmentViewTapped()
  }
  
  func getURLRange(input : String) -> [NSTextCheckingResult] {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
    return matches
  }
}
