//
//  AddEntryViewController.swift
//  Ivy
//
//  Created by Mei Zhang on 5/1/21. meizhang@usc.edu
//

import UIKit
import Firebase

class AddEntryViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var entryTV: UITextView!
    @IBOutlet weak var chosenImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTV.delegate = self
        entryTV.text = "What do you want to remember from today?"
        entryTV.textColor = UIColor.lightGray
        
        // set properties
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // support video for later
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
    }
    
    // make sure that the text becomes black when we are editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // when the view is empty put light gray text to make it look like placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Don't be shy haha"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        entryTV.resignFirstResponder()
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        // check to make sure text view is not empty
        guard let entryText = entryTV.text, !entryText.isEmpty else {
            let emptyAlertController = UIAlertController(title: "Warning!", message: "Entry must not be empty", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            emptyAlertController.addAction(okAction)
            self.present(emptyAlertController, animated: true, completion: nil)
            return
        }
        let journalSize = (UserService.currentUser?.journal?.count) ?? 0 
        
        if let image = chosenImageView.image {
            // Create a reference to the file you want to upload
            let imageName = UUID().uuidString
            let jpegData = image.jpegData(compressionQuality: 0.8)!
            let imageStorageRef = Storage.storage().reference().child("images/\(imageName)")
            let _ = imageStorageRef.putData(jpegData, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("error: no metadata? oops")
                    return
                }
                // store image download url and write to firestore
                print("size of image: ", metadata.size)
                imageStorageRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        // must send this entry back to actual user
                        UserService.currentUser?.addEntry(entry: Entry(text: entryText, photoReference: downloadURL.absoluteString, index: journalSize))
                        UserService.currentUser?.writeToFirestore()
                    }
                }
            }
        }
        else {
            UserService.currentUser?.addEntry(entry: Entry(text: entryText, index: journalSize))
        }
        
        // dismiss this view controller and return back to table
        self.navigationController!.presentingViewController!.viewWillAppear(true)
        self.navigationController!.popViewController(animated: true)
    }
    
    
    @IBAction func addPhotosTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // put the chosen image into the image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        chosenImageView.image = image
        imagePicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
    }

}
