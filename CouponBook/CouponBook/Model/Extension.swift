//
//  Extension.swift
//  Chat
//
//  Created by haniln on 2022/01/18.
//

import Foundation
import UIKit

// UILabel class
@IBDesignable
class CustomLabel: UILabel {
//    var textEdgeInsets = UIEdgeInsets.zero {
//        didSet { invalidateIntrinsicContentSize() }
//    }
//
//    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        let insetRect = bounds.inset(by: textEdgeInsets)
//        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
//        let invertedInsets = UIEdgeInsets(top: -textEdgeInsets.top, left: -textEdgeInsets.left, bottom: -textEdgeInsets.bottom, right: -textEdgeInsets.right)
//        return textRect.inset(by: invertedInsets)
//    }
//
//    override func drawText(in rect: CGRect) {
//        super.drawText(in: rect.inset(by: textEdgeInsets))
//    }
//
//    @IBInspectable
//    var paddingLeft: CGFloat {
//        set { textEdgeInsets.left = newValue }
//        get { return textEdgeInsets.left }
//    }
//
//    @IBInspectable
//    var paddingRight: CGFloat {
//        set { textEdgeInsets.right = newValue }
//        get { return textEdgeInsets.right }
//    }
//
//    @IBInspectable
//    var paddingTop: CGFloat {
//        set { textEdgeInsets.top = newValue }
//        get { return textEdgeInsets.top }
//    }
//
//    @IBInspectable
//    var paddingBottom: CGFloat {
//        set { textEdgeInsets.bottom = newValue }
//        get { return textEdgeInsets.bottom }
//    }
    @IBInspectable var topInset: CGFloat = 5.0
        @IBInspectable var bottomInset: CGFloat = 5.0
        @IBInspectable var leftInset: CGFloat = 7.0
        @IBInspectable var rightInset: CGFloat = 7.0

        override func drawText(in rect: CGRect) {
            let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            super.drawText(in: rect.inset(by: insets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + leftInset + rightInset,
                          height: size.height + topInset + bottomInset)
        }

        override var bounds: CGRect {
            didSet {
                // ensures this works within stack views if multi-line
                preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
            }
        }
    
    @IBInspectable open var letterSpacing:CGFloat = 0 {
        didSet {
            let attributedString = NSMutableAttributedString(string: self.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: self.letterSpacing, range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }
    }
    
    @IBInspectable open var lineHeight:CGFloat = 0 {
        didSet {
            let attrString = NSMutableAttributedString(string: self.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = self.lineHeight
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    }
}

// UINavigationController ------------------------------------------------------------------------------------
//https://yungsoyu.medium.com/swift-pop-gesture-swipe-back-gesture-%EB%A1%9C-%EB%92%A4%EB%A1%9C%EA%B0%80%EA%B8%B0-%EA%B5%AC%ED%98%84%ED%95%98%EA%B8%B0-7cb2d8f9e814
//class BaseNavigationController: UINavigationController {
//
//    private var duringTransition = false
//    private var disabledPopVCs = [MainViewController.self, LoginViewController.self]
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        interactivePopGestureRecognizer?.delegate = self
//        self.delegate = self
//    }
//
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        duringTransition = true
//
//        super.pushViewController(viewController, animated: animated)
//    }
//
//}
//
//extension BaseNavigationController: UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        self.duringTransition = false
//    }
//}
//
//extension BaseNavigationController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard gestureRecognizer == interactivePopGestureRecognizer,
//              let topVC = topViewController else {
//                  return true // default value
//              }
//
//        return viewControllers.count > 1 && duringTransition == false && isPopGestureEnable(topVC)
//    }
//
//    private func isPopGestureEnable(_ topVC: UIViewController) -> Bool {
//        for vc in disabledPopVCs {
//            if String(describing: type(of: topVC)) == String(describing: vc) {
//                return false
//            }
//        }
//        return true
//    }
//}

// UIView ------------------------------------------------------------------------------------
extension UIView {
    func roundCorners(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
    
    func viewToImage() -> UIImage {
      let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image(actions: { rendererContext in
          layer.render(in: rendererContext.cgContext)
      })
    }
}

// UIButton ------------------------------------------------------------------------------------
extension UIButton {
    func setGradient(color1:UIColor,color2:UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor,color2.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }

    func letterSpacing(value: CGFloat) {
        let attributedText = NSMutableAttributedString(string: (self.titleLabel?.text)!)
        attributedText.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(location: 0, length: attributedText.length))
        self.titleLabel?.attributedText = attributedText
    }
}

// UITextView ------------------------------------------------------------------------------------
extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}

// UITextField ------------------------------------------------------------------------------------
extension UITextField {
    //왼쪽에 여백 주기
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
}

// String ------------------------------------------------------------------------------------
extension String {
    func textHeight(text: String, font: UIFont, width: CGFloat) -> Int {
        let size = CGSize(width: width, height: 2000)
        return Int(text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size.height)
    }
    
    func textWidth(text: String, font: UIFont, height: CGFloat) -> Int {
        let size = CGSize(width: 2000, height: height)
        return Int(text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).size.width)
    }
    
    // 문자열 잘라내기 'from' to 'to'
    func substring(from: Int, to: Int) -> String {
        guard from < count, to >= 0, to - from >= 0 else {
            return ""
        }
        
        // Index 값 획득
        let startIndex = index(self.startIndex, offsetBy: from)
        let endIndex = index(self.startIndex, offsetBy: to)
        
        // 파싱
        return String(self[startIndex ..< endIndex])
    }
}

// Date ------------------------------------------------------------------------------------
extension Date {
    public func dateCompare(fromDate: Date) -> String {
        var strDateMessage:String = ""
        let result:ComparisonResult = self.compare(fromDate)
        switch result {
        case .orderedAscending:
            strDateMessage = "Future"
            break
        case .orderedDescending:
            strDateMessage = "Past"
            break
        case .orderedSame:
            strDateMessage = "Same"
            break
        default:
            strDateMessage = "Error"
            break
        }
        return strDateMessage
    }
}


// UIColor ------------------------------------------------------------------------------------
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

// UIViewController ------------------------------------------------------------------------------------
extension UIViewController {    
    // toast
    public func showToastMessage(_ message: String) {
        let isNotchiPhone:Double = UserDefaults.standard.double(forKey: "isNotchiPhone")
        let window = UIApplication.shared.windows.first!
        let toastLabel = UILabel(frame: CGRect(x: 16, y: window.frame.height - 60 - CGFloat(isNotchiPhone), width: window.frame.width - 32, height: 40))
        let innerLb = UILabel(frame: CGRect(x: 16, y: 0, width: toastLabel.frame.size.width - 16, height: 40))
        
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.layer.cornerRadius = 4
        toastLabel.clipsToBounds = true
        innerLb.backgroundColor = .clear
        innerLb.textColor = UIColor.white
        innerLb.numberOfLines = 1
        innerLb.font = UIFont(name: "Pretendard-Regular", size: 14)
        innerLb.text = message
        innerLb.textAlignment = .left
        
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.windows.first{$0.isKeyWindow}
            guard let window = keyWindow else { return }
            guard let topController = window.rootViewController else { return }
            toastLabel.addSubview(innerLb)
            topController.view.addSubview(toastLabel)
        } else {
            guard let topController = UIApplication.shared.keyWindow?.rootViewController else { return }
            toastLabel.addSubview(innerLb)
            topController.view.addSubview(toastLabel)
        }
        
        UIView.animate(withDuration: 2, delay: 1, options: .curveEaseOut) {
            toastLabel.alpha = 0.0
        } completion: { _ in
            toastLabel.removeFromSuperview()
        }
    }
}

// UIScrollView ------------------------------------------------------------------------------------
extension UIScrollView {
    func updateContentSize() {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        
        // 계산된 크기로 컨텐츠 사이즈 설정
        self.contentSize = CGSize(width: self.frame.width, height: unionCalculatedTotalRect.height+50)
    }
    
    private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
        var totalRect: CGRect = .zero
        
        // 모든 자식 View의 컨트롤의 크기를 재귀적으로 호출하며 최종 영역의 크기를 설정
        for subView in view.subviews {
            totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        
        // 최종 계산 영역의 크기를 반환
        return totalRect.union(view.frame)
    }
}

// family Font ------------------------------------------------------------------------------------
func familyFont() {
    let familyNames = UIFont.familyNames
    for familyName in familyNames {
        print( "Family: \(familyName.utf8)" )
        let fontNames = UIFont.fontNames(forFamilyName: familyName)
        for fontName in fontNames {
            print( "\tFont: \(fontName.utf8)") } }
}
