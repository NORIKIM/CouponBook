//
//  MainVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//

import UIKit
import CoreData

class MainVC: UIViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
//    var container: NSPersistentCloudKitContainer!
    var fetchedResultsController: NSFetchedResultsController<Coupon>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        self.container = appDelegate.persistentContainer
//        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        viewContext.automaticallyMergesChangesFromParent = true
//
//        self.managedObjectContext = viewContext
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureFetchedResultsController()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("performfetch error")
        }
        print("")
        // fetchedResultsController.sections //
    }

    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Coupon>(entityName: "Coupon")
        let sortBase = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortBase]
        fetchedResultsController = NSFetchedResultsController<Coupon>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.managedObjectContext,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
        self.fetchedResultsController.delegate = self
    }
    
    @IBAction func showAddVC(_ sender: UIButton) {
        let addVC = self.storyboard?.instantiateViewController(withIdentifier: "addVC") as! AddVC
        addVC.manageObjectContext = self.managedObjectContext
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    @IBAction func showListVC(_ sender: UIButton) {
        let listVC = self.storyboard?.instantiateViewController(withIdentifier: "listVC") as! ListVC
        listVC.managedObjectContext = self.managedObjectContext
        self.navigationController?.pushViewController(listVC, animated: true)
    }
    
}

/*
 https://www.andrewcbancroft.com/blog/ios-development/data-persistence/getting-started-with-nspersistentcloudkitcontainer/
 https://www.wwdcnotes.com/notes/wwdc19/202/
 https://icksw.tistory.com/224
 */
