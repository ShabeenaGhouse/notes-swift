//
//  AlertActionPickerControllers.swift
//  Notes
//
//  Created by shabeena on 24/03/21.
//

import UIKit
import Foundation
import MobileCoreServices
import AVFoundation

protocol AlertActionDelegateMethods: class {
  func didFinishPickingImage(image: UIImage)
}

class AlertActionPickerControllers: NSObject,UINavigationControllerDelegate,
                                    UIImagePickerControllerDelegate {
  
  lazy var imagePicker:UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    return imagePicker
  }()
  
  var sourceView: UIView?
  var attachmentButton: UIBarButtonItem?
  weak var delegate: AlertActionDelegateMethods?
  
  // MARK: - ImagePicker delegate methods
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    let mediaType = info[.mediaType] as? String
    if mediaType == String(kUTTypeImage) {
      guard let _ = info[.imageURL] as? URL else {
        if let chosenImage = info[.originalImage] as? UIImage {
          self.delegate?.didFinishPickingImage(image: chosenImage)
        }
        return
      }
    }
    if let chosenImage = info[.originalImage] as? UIImage {
      self.delegate?.didFinishPickingImage(image: chosenImage)
    }
    
    picker.dismiss(animated: true, completion: nil)
  }
  
  func addAttachmentClicked(vc: UIViewController) {
    vc.modalPresentationStyle  = .overFullScreen
    let actionSheet = UIAlertController(title: "Choose an attachment source",
                                        message: nil,
                                        preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
      if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
        self.imagePicker.sourceType = .camera
        self.imagePicker.mediaTypes = [String(kUTTypeImage)]
        self.imagePicker.cameraCaptureMode = .photo
      }
      self.checkCameraAccess(vc)
    }))
    
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.mediaTypes = [String(kUTTypeImage)]
        vc.present(self.imagePicker, animated: true, completion: nil)
      }))
    }
    
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    if sourceView == nil {
      actionSheet.popoverPresentationController?.barButtonItem = attachmentButton
      actionSheet.popoverPresentationController?.permittedArrowDirections = .down
    } else if let presenter = actionSheet.popoverPresentationController{
      presenter.sourceView = sourceView
      presenter.sourceRect = sourceView!.bounds
    }
    vc.present(actionSheet, animated: true, completion: nil)
  }
  
  private func checkCameraAccess(_ vc: UIViewController) {
    if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
      vc.present(self.imagePicker, animated: true, completion: nil)
    } else {
      AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
        DispatchQueue.main.async {
          if granted {
            vc.present(self.imagePicker, animated: true, completion: nil)
          } else {
            vc.showAlertToEnableCameraFromDeviceSettings()
          }
        }
      })
    }
  }
}
