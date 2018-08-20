//
//  ViewController.swift
//  ImageCompose
//
//  Created by Kazuo Tsubaki on 2018/08/16.
//  Copyright © 2018年 Kazuo Tsubaki. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var overImageView: UIImageView!
    @IBOutlet weak var composedImageView: UIImageView!
    @IBOutlet weak var blendModeButton: BlendModeButton!
    @IBOutlet weak var swapButton: UIButton!
    
    var imagePicker: UIImagePickerController!
    var tappedView: String = "base"
    var blender = ImageBlender()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        baseImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBaseImage(_:))))
        overImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOverImage(_:))))
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        blendModeButton.delegate = self
        
        changeSwapButtonState()
        
        authorizePhotoLibraryUsage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func blendImages() {
        guard let baseImage = baseImageView.image else { return }
        guard let overImage = overImageView.image else { return }
        blender.blendImages(baseImage: baseImage, overImage: overImage) { (image) -> (Void) in
            if image != nil {
                composedImageView.image = image
            }
        }
    }
    
    private func changeSwapButtonState() {
        swapButton.isEnabled = baseImageView.image != nil && composedImageView.image != nil
        swapButton.setTitleColor(swapButton.isEnabled ? UIColor.white : UIColor.gray, for: .normal)
    }
    
    @IBAction func swapImages(_ sender: UIButton) {
        let baseImage = overImageView.image
        let overImage = baseImageView.image
        overImageView.image = overImage
        baseImageView.image = baseImage
        blendImages()
    }
    
    @objc func tapBaseImage(_ sender: UITapGestureRecognizer) {
        tappedView = "base"
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func tapOverImage(_ sender: UITapGestureRecognizer) {
        tappedView = "over"
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveToPhotoAlbum(_ sender: Any) {
        guard let image = composedImageView.image else { return }
        guard let imageData: Data = UIImageJPEGRepresentation(image, 1.0) else { return }
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: imageData, options: nil)
        }) { (success, failure) in
            if success {
                print("Photo saved from video")
            } else {
                print("Could not save photo from video: \(String(describing: failure))")
            }
        }
    }
    
    private func authorizePhotoLibraryUsage() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { (status) in
            }
        }
    }

}

extension ViewController: BlendModeButtonDelegate {
    
    func didSelect(blendModeButton: BlendModeButton, selectedMode: CGBlendMode) {
        blender.blendMode = selectedMode
        blendImages()
        blendModeButton.resignFirstResponder()
    }
    
    func didCancel(blendModeButton: BlendModeButton) {
        blendModeButton.resignFirstResponder()
    }
    
    func selectedBlendMode(blendModeButton: BlendModeButton) -> CGBlendMode {
        return blender.blendMode
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if tappedView == "base" {
            baseImageView.image = image
        } else {
            overImageView.image = image
        }
        dismiss(animated: true, completion: nil)
        blendImages()
        changeSwapButtonState()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
