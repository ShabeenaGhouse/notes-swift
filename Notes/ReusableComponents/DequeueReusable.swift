//
//  DequeueReusable.swift
//  Notes
//
//  Created by shabeena on 23/03/21.
//

import Foundation
import UIKit

protocol DequeueReusable: class {
  static var reuseIdentifier: String { get }
}

protocol NibLoadableView {
  static var nibName: String { get }
}

// MARK: - Default Implementation
extension DequeueReusable {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension NibLoadableView {
  static var nibName: String {
    return String(describing: self)
  }
}

// MARK: - Conform Protocol
extension UITableViewCell: DequeueReusable {}
extension UITableViewHeaderFooterView: DequeueReusable {}
extension UITableViewCell: NibLoadableView {}

// MARK: - Conform Protocol
extension UICollectionViewCell: DequeueReusable {}
extension UICollectionViewCell: NibLoadableView {}

// MARK: - UITableView

extension UITableView {
  
  func register<T: UITableViewCell>(_: T.Type) {
    register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerNib<T: UITableViewCell>(_: T.Type) {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
    register(nib, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerHeaderNib<T: UITableViewHeaderFooterView>(_: T.Type) {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
    register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier,
                                         for: indexPath) as? T else {
      // to detect this in development phase, we will crash here.
      fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
    }
    return cell
  }
  
  func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(for section: Int) -> T {
    guard let cell = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T else {
      // to detect this in development phase, we will crash here.
      fatalError("Could not dequeue HeaderFooterView with identifier: \(T.reuseIdentifier)")
    }
    return cell
  }
}

// MARK: - UICollectionView

extension UICollectionView {
  
  func register<T: UICollectionViewCell>(_: T.Type) {
    register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func registerNib<T: UICollectionViewCell>(_: T.Type) {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.reuseIdentifier, bundle: bundle)
    register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier,
                                         for: indexPath) as? T else {
      // to detect this in development phase, we will crash here.
      fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
    }
    return cell
  }
}
