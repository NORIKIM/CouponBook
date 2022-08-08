//
//  DatePickerVC.swift
//  CouponBook
//
//  Created by haniln on 2022/08/05.
//

import UIKit

protocol DatePickerDelegate {
    func selectDate(str: String)
}

class DatePickerVC: UIViewController {

    @IBOutlet weak var datePickerBackView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerBackViewBottom: NSLayoutConstraint!
    var datePickerDelegate: DatePickerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backViewGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        self.view.addGestureRecognizer(backViewGesture)
        datePickerBackView.roundCorners(cornerRadius: 10, maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        show()
    }
    
    func show() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6)
        })
        UIView.animate(withDuration: 0.2, animations: {
          self.datePickerBackViewBottom.constant = 0
          self.view.layoutIfNeeded()
        })
    }
    
    @objc func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = UIColor.clear
            })
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseIn) {
                self.datePickerBackViewBottom.constant = 180
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.dismiss(animated: false, completion: nil)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        datePickerDelegate.selectDate(str: dateFormatter.string(from: datePicker.date))
    }
}
