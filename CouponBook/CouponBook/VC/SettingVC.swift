//
//  SettingVC.swift
//  CouponBook
//
//  Created by haniln on 2022/08/29.
//

import UIKit

class SettingVC: UIViewController {
    @IBOutlet weak var versionLB: UILabel!
    @IBOutlet weak var licenseLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 앱 이름 및 버전 세팅
        let CFBundleShortVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLB.text = "쿠폰북 v\(CFBundleShortVersionString!)"
        
        // 저작권
        licenseLB.text = "저작권\n아이콘:https://www.flaticon.com/free-icons/price-tag\n메뉴:https://www.flaticon.com/svg/vstatic/svg/3917/3917215.svg?token=exp=1661747211~hmac=ac8c980c3765c8560cb0f299c7b08dd3\n돋보기:https://www.flaticon.com/svg/vstatic/svg/3917/3917061.svg?token=exp=1661748625~hmac=5801bece742ed3375e5dbe772d041a3e\n알림:https://www.flaticon.com/svg/vstatic/svg/3917/3917226.svg?token=exp=1661748625~hmac=7ec3d7f9dc4312d8fbaa9498c2bdf04f\n티켓:https://www.figma.com/community/file/1071541292930320704"
    }

    @IBAction func backTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
