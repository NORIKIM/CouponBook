//
//  AddVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//

import UIKit
import CoreData

class AddVC: UIViewController, NSFetchedResultsControllerDelegate, DatePickerDelegate {
    var manageObjectContext: NSManagedObjectContext!
    var coupon: Coupon!
    var category: UIButton!
    
    // Outlet
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var expiryDateTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var addPhotoBTN: UIButton!
    @IBOutlet weak var img1View: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2View: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3View: UIView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4View: UIView!
    @IBOutlet weak var img4: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let expiryDateGesture = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        expiryDateTF.addGestureRecognizer(expiryDateGesture)
        
        addPhotoBTN.layer.cornerRadius = 20
        addPhotoBTN.layer.borderWidth = 1
        addPhotoBTN.layer.borderColor = UIColor(red: 124, green: 125, blue: 125, alpha: 1).cgColor
        if #available(iOS 15.0, *) {
            addPhotoBTN.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 13, trailing: 10)
        } else {
            addPhotoBTN.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 13, right: 10)
        }
        
        for img in [img1View,img2View,img3View,img4View] {
            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.black.cgColor
            borderLayer.lineDashPattern = [4, 4]
            borderLayer.frame = img!.bounds
            borderLayer.fillColor = nil
            borderLayer.path = UIBezierPath(roundedRect: img!.bounds, cornerRadius: 4).cgPath
            img!.layer.addSublayer(borderLayer)
        }
    }

    @objc func showDatePicker() {
        let datePickerVC = self.storyboard!.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        datePickerVC.modalPresentationStyle = .overCurrentContext
        self.present(datePickerVC, animated: false, completion: nil)
        datePickerVC.datePickerDelegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.manageObjectContext.rollback()
    }
    
    // MARK: - IBAction
    @IBAction func categoryTap(_ sender: UIButton) {
        if sender != category {
            sender.backgroundColor = UIColor(red: 210, green: 249, blue: 245, alpha: 1)
            if category != nil {
                category.backgroundColor = UIColor.white
            }
            category = sender
        }
    }
    
    @IBAction func registTap(_ sender: UIButton) {
        if self.coupon == nil {
            self.coupon = (NSEntityDescription.insertNewObject(forEntityName: Coupon.entityName,
                                                               into: self.manageObjectContext) as! Coupon)
        }
        self.coupon.category = (category.titleLabel?.text)!
        self.coupon.name = nameTF.text!
        self.coupon.expiryDate = expiryDateTF.text!
        self.coupon.price = priceTF.text
        
        do {
            try self.manageObjectContext.save()
            _ = self.navigationController?.popViewController(animated: true)
        } catch {
            let alert = UIAlertController(title: "Trouble Saving",
                                          message: "Something went wrong when trying to save the Blog Idea.  Please try again...",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: {(action: UIAlertAction) -> Void in
                                            self.manageObjectContext.rollback()
                                            self.coupon = NSEntityDescription.insertNewObject(forEntityName: Coupon.entityName, into: self.manageObjectContext) as? Coupon
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    // MARK: - DatePickerDelegate
    func selectDate(str: String) {
        expiryDateTF.text = str
    }
    
}
