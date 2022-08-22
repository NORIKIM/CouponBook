//
//  MainVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//

import UIKit
import CoreData

/*
 이미지 참조: <a href="https://www.flaticon.com/free-icons/cinema-tickets" title="cinema tickets icons">Cinema tickets icons created by murmur - Flaticon</a>
 <a href="https://www.flaticon.com/free-icons/convenience-store" title="convenience store icons">Convenience store icons created by Voysla - Flaticon</a>
 */
class MainVC: UIViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Coupon>!
    let category = CouponData.shared.setCategory()
    var couponList = [Coupon]()
    @IBOutlet weak var expiredCouponInfoLB: UILabel!
    @IBOutlet weak var infoScroll: UIScrollView!
    @IBOutlet weak var categoryScroll: UIScrollView!
    @IBOutlet weak var addBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureFetchedResultsController()
        setUI()
        setCategory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFetchedResultsController()
        do {
            try fetchedResultsController.performFetch()
            guard let coupons = fetchedResultsController.fetchedObjects else { return }
            self.couponList = coupons
            if couponList.count != 0 {
//                CouponData.shared.expire(coupons: couponList)
            }
            
//            self.setExpireCouponInfoScroll()
//            if coupons.count == 0 {
//                expiredCouponInfoLB.text = "등록된 쿠폰이 없습니다."
//            } else {
//                let coupon = CouponData().couponInfo(coupons: coupons)
//                expiredCouponInfoLB.text = coupon.expiryDate
//            }
            
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
    
    func setUI() {
        addBTN.layer.cornerRadius = 30
        
//        float inset = (self.view.bounds.size.width - cellWidth) / 2.0; // 셀의 양쪽 마진
//        let inset = 
    }
    
    func setExpireCouponInfoScroll() {
        let expireList = UserDefaults.standard.object(forKey: UserDefaultKey.closeDate.rawValue) as! [Coupon]
        var width = 0
        
        for idx in 0 ..< expireList.count {
            let background = UIImageView(frame: CGRect(x: 60, y: 10, width: infoScroll.frame.size.width - 120, height: infoScroll.frame.size.height - 20))
            background.image = UIImage(named: "ticket")
            let infoLB = UILabel(frame: CGRect(x: background.frame.origin.x - 40, y: background.frame.origin.y + 20, width: background.frame.size.width - 40, height: background.frame.size.height - 60))
            infoLB.text = "asdf"
            infoLB.textAlignment = .center
            background.addSubview(infoLB)
            infoScroll.addSubview(background)
        }
        
        infoScroll.contentSize = CGSize(width: self.view.frame.size.width, height: 170)
    }
    
    // MARK: - 등록 버튼
    @IBAction func showAddVC(_ sender: UIButton) {
        let addVC = self.storyboard?.instantiateViewController(withIdentifier: "addVC") as! AddVC
        addVC.manageObjectContext = self.managedObjectContext
        addVC.fffff = fetchedResultsController
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    // MARK: - 쿠폰 목록 카테고리
    func setCategory() {
        var width = 0
        
        for idx in 0 ..< category.count {
            if idx == 0 {
                category[idx].layer.borderColor = UIColor(red: 124, green: 247, blue: 219, alpha: 1).cgColor
            }
            
            let categoryWidth = category[idx].titleLabel?.text?.textWidth(text: (category[idx].titleLabel?.text)!, font: UIFont.systemFont(ofSize: 10), height: 30)
            category[idx].frame = CGRect(x: width + (4 * idx), y: 0, width: categoryWidth! + 60, height: 30)
            category[idx].backgroundColor = .white
            category[idx].setTitleColor(.black, for: .normal)
            category[idx].layer.borderColor = UIColor(red: 207, green: 216, blue: 220, alpha: 1).cgColor
            category[idx].layer.borderWidth = 1
            category[idx].layer.cornerRadius = 15
            category[idx].contentVerticalAlignment = .center
            if #available(iOS 15.0, *) {
                category[idx].configuration?.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 5)
            } else {
                category[idx].imageEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 25)
            }
            width += Int(CGFloat(category[idx].frame.size.width))
            categoryScroll.addSubview(category[idx])
            category[idx].tag = idx
            category[idx].addTarget(self, action: #selector(showListVC(_:)), for: .touchUpInside)
        }
        
        categoryScroll.contentSize = CGSize(width: CGFloat(width + (4 * category.count)) , height: 30)
    }
    
    // MARK: - 쿠폰 목록 show 버튼
    @objc func showListVC(_ sender: UIButton) {
        let listVC = self.storyboard?.instantiateViewController(withIdentifier: "listVC") as! ListVC
        listVC.managedObjectContext = self.managedObjectContext
        
        guard let title = sender.titleLabel?.text else { return }
        listVC.category = title
        
        self.navigationController?.pushViewController(listVC, animated: true)
    }
    
}

