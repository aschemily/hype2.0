//
//  PhotoPickerViewController.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/3/22.
//

import UIKit

//step 1. create protocol
protocol PhotoPickerDelegate: AnyObject {
    func photoPickerSelected(image: UIImage)
}

class PhotoPickerViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    //step 2. create variable to hold delegate
    weak var delegate: PhotoPickerDelegate?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
  
    func setUpViews(){
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .cyan
        imagePicker.delegate = self
    }
    
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "add a photo", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { _ in
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            //open the camera
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (_) in
            //open the photo library
            self.openGallery()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        
        present(alert, animated: true, completion: nil)
    }
    

}//end of class

extension PhotoPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "No camera access", message: "Please enable camera acccess", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "No photos access", message: "enable photo access", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Back", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage{
            guard let delegate = delegate else {return}
            delegate.photoPickerSelected(image: pickedImage)
            photoImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}
    

