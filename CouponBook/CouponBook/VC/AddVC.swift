//
//  AddVC.swift
//  CouponBook
//
//  Created by haniln on 2022/07/08.
//

import UIKit
import CoreData
import PhotosUI
import BSImagePicker

protocol AddDelegate {
    func afterAdd(isSuccess: Bool)
}

class AddVC: UIViewController, NSFetchedResultsControllerDelegate, DatePickerDelegate, UITextFieldDelegate, PHPickerViewControllerDelegate, UITextViewDelegate {
    var delegate: AddDelegate!
    // property
    var manageObjectContext: NSManagedObjectContext!
    var keyboardSize = 0
    var isKeyboardShowing = false
    var coupon: Coupon?
    var selectCategory: UIButton!
    var photoArr = [UIImageView]()
    var clearArr = [UIButton]()
    var photos = [UIImage]()
    /// for iOS 15.0* imagePic
    private var selectedAssetIdentifiers = [String]()
    private var selectedAssetIdentifierIterator: IndexingIterator<[String]>?
    private var currentAssetIdentifier: String?
    private var _selection: Any? = nil
    @available(iOS 15, *)
    var selection: [String: PHPickerResult] {
        get {
            if _selection == nil {
                _selection = [String: PHPickerResult]()
            }
            return _selection as! [String: PHPickerResult]
        }
        set {
            
        }
        
    }
    // Outlet
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var categoryTitleLB: UILabel!
    @IBOutlet weak var storeNameTitleLB: UILabel!
    @IBOutlet weak var expireTitleLB: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var expiryDateTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    /// 사진 추가
    @IBOutlet weak var addPhotoBTN: UIButton!
    @IBOutlet weak var img1View: UIView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var clear1BTN: UIButton!
    @IBOutlet weak var img2View: UIView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var clear2BTN: UIButton!
    @IBOutlet weak var img3View: UIView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var clear3BTN: UIButton!
    @IBOutlet weak var img4View: UIView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var clear4BTN: UIButton!
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
        let categoryRange = ("분류 *" as NSString).range(of: "*")
        let categoryAttributedString = NSMutableAttributedString.init(string: "분류 *")
        categoryAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: categoryRange)
        categoryTitleLB.attributedText = categoryAttributedString
        let storeRange = ("상호 *" as NSString).range(of: "*")
        let storeAttributedString = NSMutableAttributedString.init(string: "상호 *")
        storeAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: storeRange)
        storeNameTitleLB.attributedText = storeAttributedString
        let expireRange = ("유효기간 *" as NSString).range(of: "*")
        let expireAttributedString = NSMutableAttributedString.init(string: "유효기간 *")
        expireAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: expireRange)
        expireTitleLB.attributedText = expireAttributedString
        
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
//        photoSuperArr = [img1View, img2View, img3View, img4View]
        photoArr = [img1,img2,img3,img4]
        clearArr = [clear1BTN, clear2BTN, clear3BTN, clear4BTN]
        if #available(iOS 14.0, *) {
            
        }
        
        // 이미지뷰 점선 테두리 적용
        for view in [img1,img2,img3,img4] {
            let borderLayer = CAShapeLayer()
            borderLayer.strokeColor = UIColor.black.cgColor
            borderLayer.lineDashPattern = [4, 4]
            borderLayer.frame = view!.bounds
            borderLayer.fillColor = nil
            borderLayer.path = UIBezierPath(roundedRect: view!.bounds, cornerRadius: 4).cgPath
            view!.layer.addSublayer(borderLayer)
        }
        
        // 메모 입력창
        memoTV.layer.cornerRadius = 10
        memoTV.layer.borderWidth = 1
        memoTV.layer.borderColor = UIColor(red: 233, green: 233, blue: 233, alpha: 1).cgColor
        memoTV.delegate = self
        
        // 키보드
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHandler(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - @objc - 키보드
    // 키보드 핸들러
    @objc func keyboardHandler(noti: NSNotification) {
        guard let keyboardSize = (noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        self.keyboardSize = Int(keyboardSize.height)
    }
    
    // 스크롤뷰 탭하면 키보드 내림
    @objc func scrollTapKeyboardHide(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
        // 키보드 내려가면 스크롤 위치 재조정
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.scroll.contentInset = contentInsets
        self.scroll.scrollIndicatorInsets = contentInsets
        let scrollPoint = CGPoint(x: 0, y: 0)//self.scroll.frame.origin.y
        self.scroll.setContentOffset(scrollPoint, animated: false)
    }
    
    // MARK: - IBAction - 뒤로가기
    @IBAction func backTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction - 분류
    @IBAction func categoryTap(_ sender: UIButton) {
        if sender != selectCategory {
            sender.backgroundColor = UIColor(red: 210, green: 249, blue: 245, alpha: 1)
            if selectCategory != nil {
                selectCategory.backgroundColor = UIColor.white
            }
            selectCategory = sender
        }
    }
        
    // MARK: - @objc - 유효기간
    // 유효기간 텍스트필드 선택하면 데이트피커뷰 팝
    @objc func showDatePicker() {
        let datePickerVC = self.storyboard!.instantiateViewController(withIdentifier: "DatePickerVC") as! DatePickerVC
        datePickerVC.modalPresentationStyle = .overCurrentContext
        self.present(datePickerVC, animated: false, completion: nil)
        datePickerVC.datePickerDelegate = self
    }
    
    // DatePickerDelegate
    func selectDate(str: String) {
        expiryDateTF.text = str
    }
    
    // MARK: - textFieldDelegate - 금액
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
    
    // MARK: - 사진 추가
    @IBAction func photoPicTap(_ sender: UIButton) {
        if #available(iOS 15.0, *) {
            presentPicker(filter: nil)
        } else {
            imagePic()
        }
    }
    
    // PHAsset -> UIImage
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    // 사진 삭제
    @IBAction func clearPhotoTap(_ sender: UIButton) {
        let tag = sender.tag
        
        // 이미지가 하나
        if photos.count == 1 || tag == photos.count - 1 {
            photoArr[tag].image = nil
            clearArr[tag].isHidden = true
        // 이미지가 2개 이상
        } else  {
            for img in tag ..< photos.count {
                if img != photos.count - 1 {
                    photoArr[img].image = photoArr[img+1].image
                    photoArr[img+1].image = nil
                    clearArr[img+1].isHidden = true
                }
                if photoArr[img].image != nil {
                    clearArr[img].isHidden = false
                } else {
                    clearArr[img].isHidden = true
                }
            }
        }
        photos.remove(at: tag)
    }
    
    // MARK: - 메모
    // 메모 편집 시작 되면 스크롤 올림
    func textViewDidBeginEditing(_ textView: UITextView) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(keyboardSize), right: 0)
        self.scroll.contentInset = contentInsets
        self.scroll.scrollIndicatorInsets = contentInsets
        let scrollPoint = CGPoint(x: 0, y: Int(self.scroll.frame.origin.y)+35)//Int(self.scroll.frame.origin.y) + keyboardSize
        self.scroll.setContentOffset(scrollPoint, animated: true)
    }
 
    // MARK: - IBAction - 등록
    @IBAction func registTap(_ sender: UIButton) {
        if selectCategory == nil  {
            makeAlert(for: "분류를 선택해주세요.")
            return
        }
        if nameTF.text == nil || nameTF.text == "" {
            makeAlert(for: "상호를 입력해주세요.")
            return
        }
        if expiryDateTF.text == nil || expiryDateTF.text == "" {
            makeAlert(for: "유효기간을 선택해주세요.")
            return
        }
            
        let entityName =  NSEntityDescription.entity(forEntityName: Coupon.entityName, in: manageObjectContext)!
        let coupon = NSManagedObject(entity: entityName, insertInto: manageObjectContext)
        let index = UserDefaults.standard.integer(forKey: UserDefaultKey.index.rawValue)
        
        coupon.setValue(index, forKey: "index")
        coupon.setValue(selectCategory.titleLabel!.text, forKey: "category")
        coupon.setValue(nameTF.text!, forKey: "name")
        coupon.setValue(expiryDateTF.text!, forKey: "expiryDate")
        coupon.setValue(priceTF.text, forKey: "price")
        coupon.setValue(memoTV.text, forKey: "contentText")

        var images: Data?
        do {
            images = coreDataObjectFromImages(images: photos)
        } catch {
            print("image archiveData error")
        }
        coupon.setValue(images, forKeyPath: "contentImg")
        // 참고: https://blog.devgenius.io/saving-images-in-coredata-8739690d0520
        
        do {
            try self.manageObjectContext.save()
            UserDefaults.standard.set(index + 1, forKey: UserDefaultKey.index.rawValue)
            _ = self.navigationController?.popViewController(animated: true)
            self.delegate.afterAdd(isSuccess: true)
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

    // coreData에 [이미지] 저장하기
    func coreDataObjectFromImages(images: [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }
    
    // 알럿 세팅
    func makeAlert(for misInput: String) {
        let alert = UIAlertController(title: nil, message: misInput,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - extension 사진선택
// 사진첩에서 사진 선택
extension AddVC {
    // iOS 14 이하
    func imagePic() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 4 - photos.count
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = false
                
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
            let img = self.getAssetThumbnail(asset: asset)
            self.photos.append(img)
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
            let img = self.getAssetThumbnail(asset: asset)
            guard let idx = self.photos.firstIndex(of: img) else { return }
            self.photos.remove(at: idx)
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            print("Finished with selections: \(assets)")
            for idx in 0 ..< self.photos.count {
                self.photoArr[idx].image = self.photos[idx]
                self.clearArr[idx].isHidden = false
            }
        }, completion: {})
    }
    
    // iOS 15 이상
    /// 사진 선택창 present
    @available(iOS 15, *)
    private func presentPicker(filter: PHPickerFilter?) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .current
        if #available(iOS 15, *) {
            configuration.selection = .ordered
        }
        configuration.selectionLimit = 4 - photos.count
        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    /// 사진 선택이 끝난 후
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if #available(iOS 15, *) {
            let existingSelection = self.selection
            var newSelection = [String: PHPickerResult]()
            
            for result in results {
                let identifier = result.assetIdentifier!
                newSelection[identifier] = existingSelection[identifier] ?? result
            }
            
            selection = newSelection
            selectedAssetIdentifiers = results.map(\.assetIdentifier!)
            selectedAssetIdentifierIterator = selectedAssetIdentifiers.makeIterator()
            
            displayNext()
        }
    }
    
    @available(iOS 15, *)
    func displayNext() { // 15테스트 후 불필요 확인
        guard let assetIdentifier = selectedAssetIdentifierIterator?.next() else { return }
        currentAssetIdentifier = assetIdentifier
        
        let progress: Progress?
        let itemProvider = selection[assetIdentifier]!.itemProvider
        if itemProvider.canLoadObject(ofClass: PHLivePhoto.self) {
            progress = itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] livePhoto, error in
                DispatchQueue.main.async {
                    self?.handleCompletion(assetIdentifier: assetIdentifier, object: livePhoto, error: error)
                }
            }
        }
        else if itemProvider.canLoadObject(ofClass: UIImage.self) {
            progress = itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.handleCompletion(assetIdentifier: assetIdentifier, object: image, error: error)
                }
            }
        } else {
            progress = nil
        }
        
        displayProgress(progress)
    }
    
    func handleCompletion(assetIdentifier: String, object: Any?, error: Error? = nil) {
        guard currentAssetIdentifier == assetIdentifier else { return }
        if let livePhoto = object as? PHLivePhoto {
        } else if let image = object as? UIImage {
            displayImage(image)
        }
    }
    
    func displayProgress(_ progress: Progress?) {
//        imageView.image = nil
//        imageView.isHidden = true
    }

    
    func displayImage(_ image: UIImage?) {
//        imageView.image = image
//        imageView.isHidden = image == nil
    }
    
}
