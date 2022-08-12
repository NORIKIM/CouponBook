//
//  AddVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//

import UIKit
import CoreData

class AddVC: UIViewController, NSFetchedResultsControllerDelegate, DatePickerDelegate, UITextFieldDelegate {
    var manageObjectContext: NSManagedObjectContext!
    var coupon: Coupon!
    var category: UIButton!
    
    // Outlet
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var expiryDateTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    /// 사진 추가
    @IBOutlet weak var addPhotoBTN: UIButton!
    @IBOutlet weak var img1View: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2View: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3View: UIView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4View: UIView!
    @IBOutlet weak var img4: UIImageView!
    /// 메모
    @IBOutlet weak var memoTV: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.manageObjectContext.rollback()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUI() {
        // scroll tap 키보드 내림
        let scrollTapKeyboardHide = UITapGestureRecognizer(target: self, action: #selector(scrollTapKeyboardHide(sender:)))
        scroll.addGestureRecognizer(scrollTapKeyboardHide)
        
        // 유효기간 입력 텍스트 필드
        let expiryDateGesture = UITapGestureRecognizer(target: self, action: #selector(showDatePicker))
        expiryDateTF.addGestureRecognizer(expiryDateGesture)
        
        // 금액 textField delegate 연결
        priceTF.delegate = self
        
        // 사진 추가 버튼
        addPhotoBTN.layer.cornerRadius = 20
        addPhotoBTN.layer.borderWidth = 1
        addPhotoBTN.layer.borderColor = UIColor(red: 124, green: 125, blue: 125, alpha: 1).cgColor
        if #available(iOS 15.0, *) {
            addPhotoBTN.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 13, trailing: 10)
        } else {
            addPhotoBTN.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 13, right: 10)
        }
        
        // 이미지뷰 점선 테두리 적용
        for img in [img1View,img2View,img3View,img4View] {
            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.black.cgColor
            borderLayer.lineDashPattern = [4, 4]
            borderLayer.frame = img!.bounds
            borderLayer.fillColor = nil
            borderLayer.path = UIBezierPath(roundedRect: img!.bounds, cornerRadius: 4).cgPath
            img!.layer.addSublayer(borderLayer)
        }
        
        // 메모 입력창
        memoTV.layer.cornerRadius = 10
        memoTV.layer.borderWidth = 1
        memoTV.layer.borderColor = UIColor(red: 233, green: 233, blue: 233, alpha: 1).cgColor
        
        // 키보드
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - @objc
    // 키보드 핸들러
    @objc func keyboardHandler(noti: NSNotification) {
        let isKeyboardShowing = noti.name == UIResponder.keyboardWillShowNotification
        guard let keyboardSize = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        if isKeyboardShowing {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scroll.contentInset = contentInsets
            self.scroll.scrollIndicatorInsets = contentInsets
            let scrollPoint = CGPoint(x: 0, y: self.scroll.frame.origin.y + keyboardSize.height)
            self.scroll.setContentOffset(scrollPoint, animated: false)
        } else {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.scroll.contentInset = contentInsets
            self.scroll.scrollIndicatorInsets = contentInsets
            let scrollPoint = CGPoint(x: 0, y: self.scroll.frame.origin.y)
            self.scroll.setContentOffset(scrollPoint, animated: false)
        }
    }
    
    // 스크롤뷰 탭하면 키보드 내림
    @objc func scrollTapKeyboardHide(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    // 유효기간 텍스트필드 선택하면 데이트피커뷰 팝
    @objc func showDatePicker() {
        let datePickerVC = self.storyboard!.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        datePickerVC.modalPresentationStyle = .overCurrentContext
        self.present(datePickerVC, animated: false, completion: nil)
        datePickerVC.datePickerDelegate = self
    }
    
    // MARK: - textFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let numberFormat = NumberFormatter()
        numberFormat.numberStyle = .decimal
        numberFormat.locale = Locale.current // 지역에 따른 .decimal의 차이를 반영 (디바이스에 설정된 지역으로 값 설정)
        numberFormat.maximumFractionDigits = 0 // 소숫점을 허용하지 않을 때 0 설정
        
        // numberFormat.groupingSeparator = .decimal의 구분점을 의미
        // with: "" = 이 구분점을 ""으로 대체한다는 것으로 ','를 제거한다는 의미
        if let removeAllSeparator = textField.text?.replacingOccurrences(of: numberFormat.groupingSeparator, with: "") {
            var beforeFormatting = removeAllSeparator + string // ','가 제거된 문자열과 새로 입력된 문자열을 합침
            if numberFormat.number(from: string) != nil {
                if let formattedNumber = numberFormat.number(from: beforeFormatting), let formatString = numberFormat.string(from: formattedNumber) {
                    textField.text = formatString
                    return false
                }
            }
        }
        return true
    }
    
    // MARK: - IBAction
    // 뒤로가기
    @IBAction func backTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 분류 선택
    @IBAction func categoryTap(_ sender: UIButton) {
        if sender != category {
            sender.backgroundColor = UIColor(red: 210, green: 249, blue: 245, alpha: 1)
            if category != nil {
                category.backgroundColor = UIColor.white
            }
            category = sender
        }
    }
    
    // 저장
    @IBAction func registTap(_ sender: UIButton) {
        if self.coupon == nil {
            self.coupon = (NSEntityDescription.insertNewObject(forEntityName: Coupon.entityName,
                                                               into: self.manageObjectContext) as! Coupon)
        }
        self.coupon.category = (category.titleLabel?.text)!
        self.coupon.name = nameTF.text!
        self.coupon.expiryDate = expiryDateTF.text!
        self.coupon.price = priceTF.text
        
        do {
            try self.manageObjectContext.save()
            _ = self.navigationController?.popViewController(animated: true)
        } catch {
            let alert = UIAlertController(title: "Trouble Saving",
                                          message: "Something went wrong when trying to save the Blog Idea.  Please try again...",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: {(action: UIAlertAction) -> Void in
                                            self.manageObjectContext.rollback()
                                            self.coupon = NSEntityDescription.insertNewObject(forEntityName: Coupon.entityName, into: self.manageObjectContext) as? Coupon
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
        
    // MARK: - DatePickerDelegate
    func selectDate(str: String) {
        expiryDateTF.text = str
    }
    
}
