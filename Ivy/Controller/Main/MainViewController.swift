//
//  MainViewController.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21.
//

import UIKit
import Firebase

//MARK:- still need to show message with empty table
//https://stackoverflow.com/questions/15746745/handling-an-empty-uitableview-print-a-friendly-message
class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noEntryLabel: UILabel!
    @IBOutlet weak var journalTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        noEntryLabel.isHidden = true
        self.navigationItem.title = "journal"
        journalTableView.delegate = self
        journalTableView.dataSource = self
            //https://stackoverflow.com/questions/15746745/handling-an-empty-uitableview-print-a-friendly-message
        journalTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        journalTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = UserService.currentUser?.journal?.count ?? 0
        if count == 0 {
            // noEntryLabel.isHidden = false
            setEmptyMessage("There are no entries yet. Tap the + button to get started")
        }
        else {
            // noEntryLabel.isHidden = true
            journalTableView.backgroundView = nil
            journalTableView.separatorStyle = .singleLine
        }
        return count
    }
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
       // messageLabel.font = UIFont(name: "System", size: 17)
        messageLabel.sizeToFit()

        journalTableView.backgroundView = messageLabel
        journalTableView.separatorStyle = .none
    }
    
    // define custom row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0;
    }
    
    // should this have the implicitly unwrapped optional?
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // to load index in reverse order
        let index = abs(indexPath.row - (UserService.currentUser?.journal?.count ?? 0)) - 1
        let entry = UserService.currentUser?.journal?[index]
    
        if let photoReference = entry?.photoReference {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotoTableViewCell
            // Reference to an image file in Firebase Storage
            let url = URL(string: photoReference)
            let data = try? Data(contentsOf: url!)
            cell.photoView.image = UIImage(data: data!)
            cell.dateLabel?.text = entry?.getDateString(time: true)
            cell.entryLabel?.text = entry?.text
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "regularCell") as! RegularTableViewCell
            cell.dateLabel?.text = entry?.getDateString(time: true)
            cell.entryLabel?.text = entry?.text
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cellToDetail" || segue.identifier == "photoToDetail" {
            let journal = UserService.currentUser?.journal!
            let tableIndexPath = journalTableView.indexPathForSelectedRow!
            // since the indeces are reversed in the table to show most recent
            let entry = journal?[abs(tableIndexPath.row - journal!.count) - 1]
            // want to pass in entry that was selected and photo if it exists
            if let detailVC = segue.destination as? DetailViewController {
                detailVC.entry = entry
                if segue.identifier == "photoToDetail" {
                    let cell = journalTableView.cellForRow(at: tableIndexPath) as! PhotoTableViewCell
                    detailVC.entryImage = cell.photoView.image
                }
            }
        }
    }
}

