//
//  DetailViewController.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21. meizhang@usc.edu
//

import UIKit
import Firebase
import MessageUI
import NaturalLanguage

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    var entry: Entry!
    var entryImage: UIImage!
    var canMessage: Bool!
    let imagePicker = UIImagePickerController()
    let composeMsgVC = MFMessageComposeViewController()

    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var entryTextLabel: UILabel!
    @IBOutlet weak var entryPhotoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = entry.getDateString()
        messageButton.isHidden = true
        
        canMessage = createEntry()
        
        // set properties
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        // support video for later
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
        
        // add delete functionality
        if entryImage != nil {
            entryPhotoView.image = entryImage
            navigationItem.rightBarButtonItem?.title = "Edit Photo"
        }
        
    }
    
    // make sure this is in memory too (would be nice)
    override func viewWillAppear(_ animated: Bool) {
        if entryPhotoView.image == nil, let photoReference = entry.photoReference {
            let url = URL(string: photoReference)
            let data = try? Data(contentsOf: url!)
            // question is this the correct way to use dispatch (and is this necessary)
            DispatchQueue.main.async() { [weak self] in
                self!.entryPhotoView.image = UIImage(data: data!)
            }
        }
    }
    
    @IBAction func addPhotoTapped(_ sender: UIBarButtonItem) {
        // present imagePicker
        present(imagePicker, animated: true, completion: nil)
    }
    
    // does not support getting videos, put an alert thats like photos only
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        entryImage = image
        entryPhotoView.image = image
        let imageName = UUID().uuidString
        let jpegData = image.jpegData(compressionQuality: 0.8)!
   
        // Create a reference to the file you want to upload
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
                    self.entry.photoReference = downloadURL.absoluteString
                    UserService.currentUser?.journal?[self.entry.index].photoReference = downloadURL.absoluteString
                    UserService.currentUser?.writeToFirestore()
                }
            }
        }
        imagePicker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true)
    }
    
    // use NLP framework to highlight names
    // also determines if the "send message" button should be shown if it detects a name in your entry for the good mems
    func createEntry() -> Bool {
        let text = entry.text
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        let tags = tagger.tags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: [
                .omitPunctuation,
                .omitWhitespace,
                .omitOther,
                .joinNames
            ]
        )
        // see what is caught in the name tags
        var detectedNames = [String]()
        for (tag, range) in tags {
            switch tag {
            case .personalName?:
                detectedNames.append(String(text[range]))
            default:
                break
            }
        }
        // assign detail view with bolded names so they pop out
        if detectedNames.count == 0 {
            entryTextLabel.text = text
            return false
        }
        // bold the name, also also let the messageButton show to contact friendz
        else {
            print(detectedNames[0])
            entryTextLabel.attributedText = attributedText(text: text, names: detectedNames)
            if MFMessageComposeViewController.canSendText() {
                messageButton.isHidden = false
            }
            return true
        }
    }
    
    // helper function that creates text to be bold in certain areas
    func attributedText(text: String, names: [String]) -> NSAttributedString {
        let textNSString = text as NSString
        let attributedString = NSMutableAttributedString(string: textNSString as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 17.0)])
        let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)]

        for name in names {
            attributedString.addAttributes(boldFontAttribute, range: textNSString.range(of: name))
        }
        return attributedString
    }
    
    // create a message for person to send
    //https://www.andrewcbancroft.com/2014/10/28/send-text-message-in-app-using-mfmessagecomposeviewcontroller-with-swift/
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        composeVC.body  = "hey, i was looking through old memories and remembered that time we..."
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
    }
    
    // dismisses view controller when user is finished
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

}
