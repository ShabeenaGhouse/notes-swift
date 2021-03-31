//
//  NoteCollectionViewCell.swift
//  Notes
//
//  Created by shabeena on 23/03/21.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    
  @IBOutlet var containerView: UIView! 
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  
  
  func configure(note: Notes, backgroundColor: UIColor) {
    containerView.backgroundColor = backgroundColor
    if let title = note.title {
      titleLabel.text = title
    }
    if let dateString = note.createdDate, let int = Int64(dateString) {
      let date = Date(milliseconds: int)
      dateLabel.text = Utils.toDateString(date)
    }
  }
}

