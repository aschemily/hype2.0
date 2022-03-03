//
//  SignUpViewController.swift
//  Hype2.0
//
//  Created by Emily Asch on 3/2/22.
//

import UIKit

class SignUpViewController: UIViewController {
    var profilePhoto: UIImage?
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    @IBOutlet weak var photoContainerView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        fetchUsers()
    }
    
    func setUpViews(){
        photoContainerView.layer.cornerRadius = photoContainerView.frame.height / 2
        photoContainerView.clipsToBounds = true
    }
    
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let username = userNameTextField.text, !username.isEmpty,
              let bio = bioTextField.text else {return}
        
        UserController.shared.createUser(with: username, bio: bio, profilePhoto: profilePhoto) { success in
            if success{
                print("success creating user?")
                self.presentHypeListVC()
            }
        }
    }
    
    func fetchUsers(){
        UserController.shared.fetchUser { success in
            if success{
                //jump to view controller
                self.presentHypeListVC()
            }
        }
    }
    
    func presentHypeListVC(){
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "HypeList", bundle: nil)
            guard let viewController = storyboard.instantiateInitialViewController()
            else {return}
            
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPickerVC"{
            let destinationVC = segue.destination as? PhotoPickerViewController
            destinationVC?.delegate = self
        }
    }
  
    
    
    
}//end of class

extension SignUpViewController: PhotoPickerDelegate{
    func photoPickerSelected(image: UIImage) {
        self.profilePhoto = image
    }
    
    
}
