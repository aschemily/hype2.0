//
//  HypePhotoViewController.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/3/22.
//

import UIKit

class HypePhotoViewController: UIViewController {
    
    var image: UIImage?
    
    @IBOutlet weak var hypeTextField: UITextField!
    @IBOutlet weak var photoContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dissmissView()
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        guard let text = hypeTextField.text, !text.isEmpty,
              let image = image else {return}
        
        HypeController.shared.saveHype(with: text, photo: image) { success in
            if success{
                self.dissmissView()
            }
        }
    }
    func setUpViews(){
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 10
        photoContainerView.clipsToBounds = true
    }
    
    //help method
    func dissmissView(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC"{
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }

    }
    

}//end of class

extension HypePhotoViewController: PhotoPickerDelegate{
    func photoPickerSelected(image: UIImage) {
        self.image = image
    }
    
    
}
