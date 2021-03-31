//
//  Observable.swift
//  Notes
//
//  Created by shabeena on 21/03/21.
//

import Foundation

final class Observable<T> {
  typealias Listener = (T) -> Void
  
  var listener: Listener?
  var value: T {
    didSet {
      listener?(value)
    }
  }
  
  // MARK: - Initializer
  
  init(_ value: T) {
    self.value = value
  }
  
  // MARK: - Binding
  
  func bind(listener: Listener?) {
    self.listener = listener
    listener?(value)
  }
}
