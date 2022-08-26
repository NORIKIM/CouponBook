//
//  ListTBCell.swift
//  CouponBook
//
//  Created by haniln on 2022/07/22.
//

import UIKit

class ListTBCell: UITableViewCell {
    @IBOutlet weak var supView: UIView!
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var expiaryDateLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        supView.layer.cornerRadius = 10
        supView.layer.borderColor = UIColor(red: 224, green: 224, blue: 224, alpha: 1).cgColor
        supView.layer.borderWidth = 1
        categoryImg.layer.cornerRadius = 20
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
