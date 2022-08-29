//
//  DetailVC.swift
//  CouponBook
//
//  Created by haniln on 2022/08/29.
//

import UIKit

class DetailVC: UIViewController {
    // outlet
    @IBOutlet weak var categoryLB: CustomLabel!
    @IBOutlet weak var shopNameLB: UILabel!
    @IBOutlet weak var expireLB: UILabel!
    @IBOutlet weak var priceTitleLB: UILabel!
    @IBOutlet weak var priceLB: UILabel!
    @IBOutlet weak var imageSV: UIStackView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var memoTitleLB: UILabel!
    @IBOutlet weak var memoLB: UILabel!
    @IBOutlet weak var memoLBTop: NSLayoutConstraint!
    // property
    var coupon: Coupon?
    var imgArr = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Family: Apple SD Gothic Neo
             Font: AppleSDGothicNeo-Regular
             Font: AppleSDGothicNeo-Thin
             Font: AppleSDGothicNeo-UltraLight
             Font: AppleSDGothicNeo-Light
             Font: AppleSDGothicNeo-Medium
             Font: AppleSDGothicNeo-SemiBold
             Font: AppleSDGothicNeo-Bold
         */
        setUI()
    }

    func setUI() {
        guard let coupon = coupon else { return }
        // 분류
        let categoryWidth = (coupon.category.textWidth(text: coupon.category, font: UIFont(name: "AppleSDGothicNeo-Regular", size: 17)!, height: 21)) + 20
        categoryLB.frame.size.width = CGFloat(categoryWidth)
        categoryLB.layer.cornerRadius = 10
        categoryLB.layer.borderWidth = 1
        categoryLB.layer.borderColor = UIColor.black.cgColor
        categoryLB.text = coupon.category
        // 상호
        shopNameLB.text = coupon.name
        // 유효기간
        expireLB.text = coupon.expiryDate
        // 금액
        priceLB.text = coupon.price
        // 이미지, 메모
        imgArr = [img1, img2, img3, img4]
        let img =  imagesFromCoreData(object: coupon.contentImg)
        let memo = coupon.contentText
        
        // 이미지 O, 메모 O
        if img != nil && (memo != nil && memo != "") {
            imageSV.isHidden = false
            memoTitleLB.isHidden = false
            memoLB.isHidden = false
            for idx in 0 ..< img!.count {
                imgArr[idx].image = img![idx]
            }
            memoLB.text = memo
        }
        // 이미지 X, 메모 X
        if img == nil && (memo == nil || memo == "") {
            imageSV.isHidden = true
            memoTitleLB.isHidden = true
            memoLB.isHidden = true
        }
        // 이미지 O, 메모 X
        if img != nil && (memo == nil || memo == "") {
            imageSV.isHidden = false
            memoTitleLB.isHidden = true
            memoLB.isHidden = true
            for idx in 0 ..< img!.count {
                imgArr[idx].image = img![idx]
            }
        }
        // 이미지 X, 메모 O
        if img == nil && (memo != nil && memo != "") {
            imageSV.isHidden = true
            memoTitleLB.isHidden = false
            memoLB.isHidden = false
            memoLB.text = memo
            memoLBTop.isActive = false
            memoLBTop = NSLayoutConstraint(item: memoLB, attribute: .top, relatedBy: .equal, toItem: priceTitleLB, attribute: .bottom, multiplier: 1, constant: 20)
            memoLBTop.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    // convert data to image
    func imagesFromCoreData(object: Data?) -> [UIImage]? {
        var retVal = [UIImage]()
        guard let object = object else { return nil }
        
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
            for data in dataArray {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retVal.append(image)
                }
            }
        }
        return retVal
    }
    
    @IBAction func backTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
