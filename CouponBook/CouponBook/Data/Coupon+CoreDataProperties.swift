//
//  Coupon+CoreDataProperties.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//
//

import Foundation
import CoreData


extension Coupon {
    static var entityName: String { return "Coupon" }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Coupon> {
        return NSFetchRequest<Coupon>(entityName: "Coupon")
    }

    @NSManaged public var category: String
    @NSManaged public var name: String
    @NSManaged public var price: String?
    @NSManaged public var expiryDate: String
    @NSManaged public var contentText: String?
    @NSManaged public var contentImg: Data?

}

extension Coupon : Identifiable {

}
