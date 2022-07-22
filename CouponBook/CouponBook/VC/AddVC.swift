//
//  AddVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//

import UIKit
import CoreData

class AddVC: UIViewController, NSFetchedResultsControllerDelegate {
    var manageObjectContext: NSManagedObjectContext!
    var coupon: Coupon!
    // Outlet
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var expiryDateTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func registTap(_ sender: UIButton) {
        if self.coupon == nil {
            self.coupon = (NSEntityDescription.insertNewObject(forEntityName: Coupon.entityName,
                                                                 into: self.manageObjectContext) as! Coupon)
        }
        
        self.coupon.category = categoryTF.text!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.manageObjectContext.rollback()
    }
    
}
