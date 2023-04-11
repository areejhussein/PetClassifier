//
//  ViewController.swift
//  PetClassifier
//
//  Created by Areej Hussein on 11/04/2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    var pickedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imagePicker.delegate = self
//        imagePicker.sourceType = .camera
//        imagePicker.allowsEditing = true
    }

    // MARK: ACTION
    @IBAction func chooseImageTapped(_ sender: UIBarButtonItem) {
        
        showPickerOptions()
    }
    
    //MARK: METHODS
    func classifyImage(chosenImage: CIImage) {
        
//        guard let model = try? VNCoreMLModel(for: PetImageClassifier().model) else {
//            fatalError("Couldn't load model")
//        }
        guard let mlModel = try? PetImageClassifier(configuration: .init()).model,
              let model = try? VNCoreMLModel(for: mlModel) else {
            fatalError("Failed to load detector!")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let result = request.results?.first as? VNClassificationObservation else {
                fatalError("Couldn't complete classfication")
            }
            
            self.navigationItem.title = result.identifier.capitalized
            
        }
        
        let handler = VNImageRequestHandler(ciImage: chosenImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    func showPickerOptions() {
        
        let alert = UIAlertController(title: "Select a photo", message: "Choose a photo from library or camera.", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { [weak self] action in
            
            guard let self = self else {
                return
            }
            
            let libraryPicker = self.imagePicker(sourceType: .photoLibrary)
            libraryPicker.delegate = self
            libraryPicker.allowsEditing = true
            self.present(libraryPicker, animated: true)
            
  }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] action in
            
            guard let self = self else {
                return
            }
            
            let cameraPicker = self.imagePicker(sourceType: .camera)
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(libraryAction)
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalPickedImage = info[.originalImage] as? UIImage {
            
            guard let ciImage = CIImage(image: originalPickedImage) else {
                fatalError("Error Converting to CIImage.")
            }
            
            pickedImage = originalPickedImage
            imageView.image = pickedImage
            
            classifyImage(chosenImage: ciImage)
        }
        
        self.dismiss(animated: true)
    }
}

