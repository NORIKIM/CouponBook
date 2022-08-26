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
class MainVC: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Coupon>!
    let category = CouponData.shared.setCategory()
    var couponList = [Coupon]()
    @IBOutlet weak var appTitleLB: UILabel!
    @IBOutlet weak var expireCouponCV: UICollectionView!
    @IBOutlet weak var categoryScroll: UIScrollView!
    @IBOutlet weak var addBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFetchedResultsController()
//        do {
//            try fetchedResultsController.performFetch()
//            guard let coupons = fetchedResultsController.fetchedObjects else { return }
//            self.couponList = coupons
//        } catch {
//            print("performfetch error")
//        }
    }

    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Coupon>(entityName: "Coupon")
        let sortBase = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortBase]
        fetchedResultsController = NSFetchedResultsController<Coupon>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.managedObjectContext,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            guard let coupons = fetchedResultsController.fetchedObjects else { return }
            self.couponList = coupons
        } catch {
            print("performfetch error")
        }
    }
    
    func setUI() {
        // 앱 이름 및 버전 세팅
        let CFBundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        appTitleLB.text = "v\(CFBundleShortVersionString!)"
        
        // 쿠폰 스크롤 마진 설정
        let contentWidth = self.view.frame.size.width - 120
        let inset = (self.view.bounds.size.width - contentWidth) / 2.0 // 셀의 양쪽 마진
        expireCouponCV.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        expireCouponCV.register(UINib(nibName: "ExpireCouponCell", bundle: nil), forCellWithReuseIdentifier: "ExpireCouponCell")
        expireCouponCV.delegate = self
        expireCouponCV.dataSource = self
        
        // 등록 버튼 세팅
        addBTN.layer.cornerRadius = 30
        
        // 카테고리 세팅
        setCategory()
    }
    
    // MARK: - AddVC.Delegate - 쿠폰 등록 후 호출
    func afterAdd(isSuccess: Bool) {
        if isSuccess {
            configureFetchedResultsController()
            CouponData.shared.expire(coupons: couponList)
            expireCouponCV.reloadData()
        }
    }
    
    // MARK: - collectionView - 만료 임박
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let expireList = UserDefaults.standard.object(forKey:UserDefaultKey.closeDate.rawValue) as? [Int32]
        if expireList == nil {
            return 1
        }
        return expireList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpireCouponCell", for: indexPath) as! ExpireCouponCell
        if let expireList = UserDefaults.standard.object(forKey:UserDefaultKey.closeDate.rawValue) as? [Int32] {
            let idx = Int(expireList[indexPath.item])
            cell.infoLB.text = "\(couponList[idx].name)\n\(couponList[idx].expiryDate)"
        } else {
            cell.infoLB.text = "등록"
        }

        return cell
    }
    
    // flowlayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width - 120, height: expireCouponCV.frame.size.height)
    }
    
    // MARK: - 등록 버튼
    @IBAction func showAddVC(_ sender: UIButton) {
        let addVC = self.storyboard?.instantiateViewController(withIdentifier: "addVC") as! AddVC
        addVC.manageObjectContext = self.managedObjectContext
        addVC.delegate = self
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

