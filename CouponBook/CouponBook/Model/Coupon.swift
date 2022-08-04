//
//  Coupon.swift
//  CouponBook
//
//  Created by haniln on 2022/07/21.
//

import Foundation
import CoreData

// userDefault key enum
enum UserDefaultKey: String {
    case closeDate = "closeDate"
}

// 가장 빨리 써야 하는 쿠폰
struct ExpireCoupon {
    func couponInfo(coupons:[Coupon]) -> Coupon {
        if coupons.count > 0 && coupons.count == 1 {
            UserDefaults.standard.set(coupons[0].expiryDate, forKey: UserDefaultKey.closeDate.rawValue)
            return coupons[0]
        } else {
            let date = UserDefaults.standard.string(forKey: UserDefaultKey.closeDate.rawValue)!
            if coupons[coupons.count - 1].expiryDate > date {
                UserDefaults.standard.set(coupons[coupons.count - 1].expiryDate, forKey: UserDefaultKey.closeDate.rawValue)
                return coupons[coupons.count - 1]
            }
        }
        return Coupon()
    }
}


