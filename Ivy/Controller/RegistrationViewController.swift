//
//  ViewController.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21.
//

import UIKit
import Firebase

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.isEnabled = false
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        confirmPasswordTF.delegate = self
        phoneNumberTF.delegate = self
        
        // make sure that this text label is hidden initially
        errorLabel.textColor = UIColor.lightGray
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        firstNameTF.resignFirstResponder()
        lastNameTF.resignFirstResponder()
        emailTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        confirmPasswordTF.resignFirstResponder()
        phoneNumberTF.resignFirstResponder()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (firstNameTF.text?.isEmpty)! || (lastNameTF.text?.isEmpty)! || (emailTF.text?.isEmpty)! || (passwordTF.text?.isEmpty)! || (confirmPasswordTF.text?.isEmpty)! || (phoneNumberTF.text?.isEmpty)! {
            registerButton.isEnabled = false
        } else {
            registerButton.isEnabled = true
        }
    }
    
    @IBAction func registerDidTapped(_ sender: UIButton) {
        // make sure everything
        guard let firstName = firstNameTF.text, !firstName.isEmpty,
              let lastName = lastNameTF.text, !lastName.isEmpty,
              let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTF.text, !confirmPassword.isEmpty,
              let phoneNumber = phoneNumberTF.text, !phoneNumber.isEmpty else {
            errorLabel.text = "All fields required"
            errorLabel.isHidden = false
            return
        }
        // validate email
        if !isValidEmail(email) && !errorLabel.text!.isEmpty {
            errorLabel.text = "Must put in valid email address"
            errorLabel.isHidden = false
            return
        }
        // make sure passwords are the same
        if password != confirmPassword {
            errorLabel.text = "Passwords must match"
            errorLabel.isHidden = false
            return
        }
        // phone number should have 10 digits
        if phoneNumber.count != 10 {
            errorLabel.text = "Must put in valid phone number"
            errorLabel.isHidden = false
            return
        }
        // create the user in Firebase Auth and Firestore
        // for later : print more specific error codes ? and add spinner
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.isHidden = false
                print(error)
                return
            }
            else {
                self.errorLabel.text =  "Creating your profile..."
            }
            self.errorLabel.isHidden = false
            let uid = authResult!.user.uid
            Firestore.firestore().collection("users").document(uid).setData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "phoneNumber": Int(phoneNumber)!
            ])
            UserService.currentUser = User(uid: uid, firstName: firstName, lastName: lastName, email: email, phoneNumber: Int(phoneNumber)!)
            self.performSegue(withIdentifier: "registerToMain", sender: self)
        }
        
    }
    
    // function using regex that checks if something is a valid email or not
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}
