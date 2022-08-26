//
//  Coupon.swift
//  CouponBook
//
//  Created by haniln on 2022/07/21.
//

import Foundation
import CoreData
import UIKit

// userDefault key enum
enum UserDefaultKey: String {
    case closeDate = "closeDate"
    case index = "index"
}

struct CouponData {
    static let shared = CouponData()
    let category = [["분류":"전체", "이미지":""],
                    ["분류":"카페", "이미지":"cafe"],
                    ["분류":"음식점", "이미지":"food"],
                    ["분류":"편의점", "이미지":"store"],
                    ["분류":"쇼핑", "이미지":"shop"]]
    
    // 유효기간 임박 쿠폰
    func expire(coupons:[Coupon]) {
        let latestCoupon = coupons[coupons.count - 1]
        var expireCouponList = [Int32]()
        let encodedData: Data
        if coupons.count == 1 {
            UserDefaults.standard.set([coupons[0].index], forKey: UserDefaultKey.closeDate.rawValue)
        } else {
            let expire = UserDefaults.standard.object(forKey: UserDefaultKey.closeDate.rawValue) as! [Int32]
            let compare = coupons[Int(expire[0])]
            if compare.expiryDate > latestCoupon.expiryDate { // 기존 임박쿠폰 날짜 > 새로 추가된 쿠폰 날짜 (= 새로 추가된 쿠폰의 날짜가 더 임박하다)
                UserDefaults.standard.set([latestCoupon.index], forKey: UserDefaultKey.closeDate.rawValue)
            } else if compare.expiryDate < latestCoupon.expiryDate { // 기존 임박쿠폰 날짜 < 새로 추가된 쿠폰 날짜 (= 새로 추가된 쿠폰의 날짜가 더 넉넉하다)
                return
            } else { // 기존 임박쿠폰 날짜 == 새로 추가된 쿠폰 날짜 (= 새로 추가된 쿠폰의 날짜와 기존 임박쿠폰의 날짜가 같다)
                for idx in expire {
                    expireCouponList.append(idx)
                }
                expireCouponList.append(latestCoupon.index)
                UserDefaults.standard.set(expireCouponList, forKey: UserDefaultKey.closeDate.rawValue)
            }
        }
    }
    
    func setCategory() -> [UIButton] {
        var buttonArr = [UIButton]()
        for btn in 0 ..< category.count {
            let button  = UIButton()
            let title = category[btn]["분류"]
            let img = category[btn]["이미지"]!
            button.setTitle(title, for: .normal)
//            button.setImage(UIImage(named: img), for: .normal)
            buttonArr.append(button)
        }
        return buttonArr
    }
    
}


