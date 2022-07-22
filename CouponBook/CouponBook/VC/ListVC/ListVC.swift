//
//  ListVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/22.
//

import UIKit
import CoreData

class ListVC: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Coupon>!
    @IBOutlet weak var listTB: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listTB.delegate = self
        listTB.dataSource = self
        listTB.register(UINib(nibName: "ListTBCell", bundle: nil), forCellReuseIdentifier: "listCell")
        listTB.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureFetchedResultsController()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("performfetch error")
        }
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
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - tableView
    public func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTBCell
        let coupon = fetchedResultsController.object(at: indexPath)
        
        cell.nameLB.text = coupon.name
        cell.expiaryDateLB.text = coupon.expiryDate
        
        return cell
    }
    
}
