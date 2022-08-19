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
}

struct CouponData {
    let category = [["분류":"전체", "이미지":""],
                    ["분류":"카페", "이미지":"cafe"],
                    ["분류":"음식점", "이미지":"food"],
                    ["분류":"편의점", "이미지":"store"],
                    ["분류":"쇼핑", "이미지":"shop"]]
    
    // 유효기간 임박 쿠폰
    func couponInfo(coupons:[Coupon]) -> Coupon {
        if coupons.count > 0 && coupons.count == 1 {
            UserDefaults.standard.set(coupons[0].expiryDate, forKey: UserDefaultKey.closeDate.rawValue)
            return coupons[0]
        } else {
            let date = UserDefaults.standard.string(forKey: UserDefaultKey.closeDate.rawValue)!
            if coupons[coupons.count - 1].expiryDate < date {
                UserDefaults.standard.set(coupons[coupons.count - 1].expiryDate, forKey: UserDefaultKey.closeDate.rawValue)
                return coupons[coupons.count - 1]
            }
            return coupons[coupons.count - 1]
        }
        
    }
    
    func setCategory() -> [UIButton] {
        var buttonArr = [UIButton]()
        for btn in 0 ..< category.count {
            let button  = UIButton()
            let title = category[btn]["분류"]
            let img = category[btn]["이미지"]!
            button.setTitle(title, for: .normal)
            button.setImage(UIImage(named: img), for: .normal)
            buttonArr.append(button)
        }
        return buttonArr
    }
    
}


