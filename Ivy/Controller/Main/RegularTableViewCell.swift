//
//  RegularTableViewCell.swift
//  Ivy
//
//  Created by Mei Zhang on 4/29/21.
//

import UIKit

//https://developer.apple.com/documentation/uikit/views_and_controls/table_views/configuring_the_cells_for_your_table
//https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/custom-cells/
class RegularTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var entryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
