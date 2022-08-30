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
class MainVC: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AddDelegate, UITableViewDelegate, UITableViewDataSource {
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Coupon>!
    let category = CouponData.shared.setCategory()
    var couponList = [Coupon]()
    var selectCategory = "전체"
    var headerView: HeaderView?
    @IBOutlet weak var expireCouponCV: UICollectionView!
    @IBOutlet weak var categoryScroll: UIScrollView!
    @IBOutlet weak var addBTN: UIButton!
    @IBOutlet weak var couponTBV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        headerView = expireCouponCV as? HeaderView
//        headerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        headerView?.scrollView = couponTBV
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFetchedResultsController()
    }

    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Coupon>(entityName: "Coupon")
        let sortBase = NSSortDescriptor(key: "index", ascending: true)
        fetchRequest.sortDescriptors = [sortBase]
        if selectCategory != "전체" {
        let predicate = NSPredicate(format: "category = %@", selectCategory)
        fetchRequest.predicate = predicate
        }
        fetchedResultsController = NSFetchedResultsController<Coupon>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.managedObjectContext,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
        self.fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            guard let coupons = fetchedResultsController.fetchedObjects else { return }
            self.couponList = coupons
            couponTBV.reloadData()
        } catch {
            print("performfetch error")
        }
    }
 
    func setUI() {
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
        
        couponTBV.register(UINib(nibName: "ListTBCell", bundle: nil), forCellReuseIdentifier: "listCell")
        couponTBV.delegate = self
        couponTBV.dataSource = self
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
            cell.infoLB.text = "등록된 쿠폰이 없습니다.\n쿠폰을 등록해주세요!"
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
    
    // 쿠폰 목록 show
    @objc func showListVC(_ sender: UIButton) {
        selectCategory = sender.currentTitle!
        configureFetchedResultsController()
    }
    
    //MARK: - 쿠폰 목록 tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        couponList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTBCell
        let coupon = couponList[indexPath.row]
        
        cell.storeImgView.image = UIImage(named: storeImage(coupon.name))
        cell.nameLB.text = coupon.name
        cell.expiaryDateLB.text = coupon.expiryDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        detailVC.coupon = couponList[index]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func storeImage(_ storeName: String) -> String {
        switch storeName {
        case "스타벅스", "스벅", "starbucks", "starbuck":
            return "스타벅스"
        case "cu", "씨유", "시유":
            return "cu"
        case "seven11", "seven24/7", "seven 11", "seven 24/7", "seven 24", "세븐일레븐", "세븐11", "세븐":
            return "seven11"
        case "bluebottle","blue bottle", "블루보틀", "블루 보틀":
            return "블루보틀"
        case "coffeebean", "커피빈":
            return "커피빈"
        case _ where storeName.contains("롯데"), _ where storeName.contains("lotte"):
            return "lotte"
        default:
            return "default"
        }
    }
}

