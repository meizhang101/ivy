//
//  PhotoTableViewCell.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21.
//

import UIKit

// should I subclass this from the Regular Table View Cell? 
class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var entryLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
