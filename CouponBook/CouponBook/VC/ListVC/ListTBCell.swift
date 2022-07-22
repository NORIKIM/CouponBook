//
//  ListTBCell.swift
//  CouponBook
//
//  Created by haniln on 2022/07/22.
//

import UIKit

class ListTBCell: UITableViewCell {
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var expiaryDateLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .white
        nameLB.backgroundColor = .white
        nameLB.textColor = .black
        expiaryDateLB.backgroundColor = .white
        expiaryDateLB.textColor = .black
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
