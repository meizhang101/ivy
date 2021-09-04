//
//  LoginViewController.swift
//  
//
//  Created by Mei Zhang on 5/1/21. meizhang@usc.edu
//

import UIKit
import Firebase
import CodableFirebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make sure error is hidden and text is light grey
        errorTextLabel.textColor = UIColor.lightGray
        errorTextLabel.isHidden = true
    }
    
    // for later: add a spinner once the button is tapped
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let email = emailTF.text, let password = passwordTF.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.errorTextLabel.isHidden = false
                    print(error)
                    return
                }
                // remove warning to let user know they are being logged in now
                self.errorTextLabel.text = "Logging you in..."
                self.errorTextLabel.isHidden = false
                // retrieve user from this
                guard let uid = authResult?.user.uid else {
                    print("bad auth result from login button")
                    return
                }
                // create the singleton and pass relevant info into the main view controller
                Firestore.firestore().collection("users").document(uid).getDocument { document, error in
                    if let _ = error {
                        print("Login button err: This user document does not exist")
                    }
                    else if let document = document {
                        UserService.currentUser = try! FirestoreDecoder().decode(User.self, from: document.data()!)
                        UserService.currentUser?.uid = uid
                        // need to perform segue only after this is done
                        self.performSegue(withIdentifier: "loginToMain", sender: self)
                        return
                    }
                }
            }
        }
        
    }

}
