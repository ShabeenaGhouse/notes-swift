//
//  AnnotationViewController.swift
//  Notes
//
//  Created by shabeena on 24/03/21.
//

import UIKit
import AVFoundation
import MobileCoreServices
import NXDrawKit

protocol imageAnnotationDelegate: class {
  func imageAnnotated(image: UIImage)
}

class AnnotationViewController: UIViewController {
  weak var canvasView: Canvas?
  weak var paletteView: Palette?
  weak var toolBar: ToolBar?
  weak var delegate: imageAnnotationDelegate?
  var selectedImage = UIImage()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.initialize()
  }
  
  fileprivate func initialize() {
    self.setupCanvas()
    self.setupPalette()
    self.setupToolBar()
  }
  
  fileprivate func setupPalette() {
    self.view.backgroundColor = UIColor.white
    
    let paletteView = Palette()
    paletteView.delegate = self
    paletteView.setup()
    self.view.addSubview(paletteView)
    self.paletteView = paletteView
    let paletteHeight = paletteView.paletteHeight()
    paletteView.frame = CGRect(x: 0,
                               y: self.view.frame.height - paletteHeight,
                               width: self.view.frame.width,
                               height: paletteHeight)
  }
  
  fileprivate func setupToolBar() {
    let height = (self.paletteView?.frame)!.height * 0.25
    let startY = self.view.frame.height - (paletteView?.frame)!.height - height
    let toolBar = ToolBar()
    toolBar.frame = CGRect(x: 0, y: startY, width: self.view.frame.width, height: height)
    toolBar.undoButton?.addTarget(self,
                                  action: #selector(onClickUndoButton),
                                  for: .touchUpInside)
    toolBar.redoButton?.addTarget(self,
                                  action: #selector(onClickRedoButton),
                                  for: .touchUpInside)
    toolBar.loadButton?.isHidden = true
    toolBar.saveButton?.addTarget(self,
                                  action: #selector(onClickSaveButton),
                                  for: .touchUpInside)
    toolBar.saveButton?.isEnabled = true
    toolBar.clearButton?.addTarget(self,
                                   action: #selector(onClickClearButton),
                                   for: .touchUpInside)
    toolBar.loadButton?.isEnabled = true
    self.view.addSubview(toolBar)
    self.toolBar = toolBar
  }
  
  fileprivate func setupCanvas() {
    let canvasView = Canvas(canvasId: nil, backgroundImage: selectedImage)
    canvasView.frame = CGRect(x: 20, y: 180,
                              width: self.view.frame.size.width - 40,
                              height: self.view.frame.size.width - 40)
    canvasView.delegate = self
    canvasView.layer.borderColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 0.8).cgColor
    canvasView.layer.borderWidth = 2.0
    canvasView.layer.cornerRadius = 5.0
    canvasView.clipsToBounds = true
    self.view.addSubview(canvasView)
    self.canvasView = canvasView
  }
  
  fileprivate func updateToolBarButtonStatus(_ canvas: Canvas) {
    self.toolBar?.undoButton?.isEnabled = canvas.canUndo()
    self.toolBar?.redoButton?.isEnabled = canvas.canRedo()
    self.toolBar?.saveButton?.isEnabled = true// canvas.canSave()
    self.toolBar?.clearButton?.isEnabled = canvas.canClear()
  }
  
  @objc func onClickUndoButton() {
    self.canvasView?.undo()
  }
  
  @objc func onClickRedoButton() {
    self.canvasView?.redo()
  }
  
  @objc func onClickSaveButton() {
    self.canvasView?.save()
  }
  
  @objc func onClickClearButton() {
    self.canvasView?.clear()
  }
  
  // MARK: - Storyboard Instance
  
  static func storyboardInstance() -> AnnotationViewController {
    return AnnotationViewController.instantiate(fromStoryboard: .Annotation)
  }
  //
}

// MARK: - CanvasDelegate
extension AnnotationViewController: CanvasDelegate {
  func brush() -> Brush? {
    return self.paletteView?.currentBrush()
  }
  
  func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
    self.updateToolBarButtonStatus(canvas)
  }
  
  func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
    if let annotedImage = image {
      delegate?.imageAnnotated(image: annotedImage)
      popViewController()
    }
  }
}

// MARK: - PaletteDelegate
extension AnnotationViewController: PaletteDelegate {
  // tag can be 1 ... 12
  func colorWithTag(_ tag: NSInteger) -> UIColor? {
    if tag == 4 {
      return UIColor.clear
    }
    return nil
  }
}
