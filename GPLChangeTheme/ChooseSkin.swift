//
//  ChooseSkin.swift
//  ChameleonSwift_Example
//
//  Created by 顾鹏凌 on 2019/10/22.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Foundation

final public class ThemeDataWraper<T> {
    public var value :T

    init(value:T) {
        self.value = value
    }
}

class ThemeData {
    let extData: Any

    init<T>(data:T) {
        extData = ThemeDataWraper(value: data)
    }

    func data<T>() -> T? {
        if let d = extData as? ThemeDataWraper<T> {
            return d.value
        }
        return nil
    }

}

fileprivate class ThemeDataCenter {
    fileprivate static let shared = ThemeDataCenter(data: Optional<String>.none)

    fileprivate var currentData: ThemeData

    class func setThemeData<T>(_ obj: T) {
        shared.currentData = ThemeData(data: obj)
    }

    fileprivate init<T>(data: T) {
        currentData = ThemeData(data: data)
    }

    class func themeData<T>() -> T? {
        return shared.currentData.data()
    }
}

private let defaults = UserDefaults.standard
private let lastChooseThemeKey = "lastChooseThemeKey"

@objc public final class ThemeConfig: NSObject {
    public static let shared = ThemeConfig()

    public static var `default` = "Light"
    public static var dark = "Dark"

    fileprivate override init() {
        super.init()
        self.swizzledConfig()
    }

    public func setThemeData<T>(data: T) {
        ThemeDataCenter.setThemeData(data)
    }

    fileprivate func swizzledConfig() {
        UIView.overwriteInstanceMethod(originalSelector: #selector(UIView.awakeFromNib), rewriteSelector: #selector(UIView.theme_awakeFromNib))
        UIView.overwriteInstanceMethod(originalSelector: #selector(UIView.didMoveToWindow), rewriteSelector: #selector(UIView.theme_didMoveToWindow))
        UIViewController.overwriteInstanceMethod(originalSelector: #selector(UIViewController.awakeFromNib), rewriteSelector: #selector(UIViewController.theme_awakeFromNib))
        UIViewController.overwriteInstanceMethod(originalSelector: #selector(UIViewController.viewWillAppear(_:)), rewriteSelector: #selector(UIViewController.theme_viewWillAppear(_:)))
        UIViewController.overwriteInstanceMethod(originalSelector: #selector(UIViewController.viewDidDisappear(_:)), rewriteSelector: #selector(UIViewController.theme_viewDidDisappear(_:)))
    }

//    @objc public fileprivate(set) static var currentThemeName = "Light"

    static func storeSkinTheme() {
        if let theme = ThemeHelper<String>.current {
            defaults.set(theme, forKey: lastChooseThemeKey)
        }
    }

    static func restoreSkinTheme() {
        let name = defaults.string(forKey: lastChooseThemeKey) ?? ThemeConfig.default

        ThemeConfig.shared.setThemeData(data: name)
    }
}


// Protocol
extension SkinReplaceProtocol {
    func runWrapper(data: ThemeData) {
        let preData = self.data
        
        for child in childrens {
            child.runWrapper(data: data)
        }

        self.data = data
        before()

        callback.replaceTheme(now: data.extData, pre: preData?.extData)

        refreshThemeBlock?(data.extData,preData?.extData)

        after()
    }
}

open class ThemeBase<T: SkinReplaceUIProtocol>: SkinReplaceProtocol {
    unowned var owner: T

    fileprivate init(owner: T) {
        self.owner = owner
    }

    var data: ThemeData?

    var refreshThemeBlock: RefreshThemeBlock?

    var childrens: [SkinReplaceProtocol] {
        return []
    }

    var callback: SkinReplaceUIProtocol {
        return owner
    }

    func before() {}

    func after() {}

    public func refesh<T>(data: T) {
        runWrapper(data: ThemeData(data: data))
    }

    public func refesh() {
        if let data = self.data {
            runWrapper(data: data)
        }else {
            runWrapper(data: ThemeDataCenter.shared.currentData)
        }
    }
}

// UIView
private var kChameleonKey: Void?
class ThemeBaseView: ThemeBase<UIView> {
    override var childrens: [SkinReplaceProtocol] {
        return owner.subviews.compactMap({ $0.theme })
    }
}

public extension UIView {
    var theme: ThemeBase<UIView> {
        get {
            if let pre = objc_getAssociatedObject(self, &kChameleonKey) as? ThemeBase<UIView> {
                return pre
            }
            let now = ThemeBaseView(owner: self)
            objc_setAssociatedObject(self, &kChameleonKey, now, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return now
        }
    }
}

// UIViewController
class ThemeBaseViewController: ThemeBase<UIViewController> {
    override var childrens: [SkinReplaceProtocol] {
        return owner.children.compactMap({ $0.theme })
    }

    override func after() {
        owner.setNeedsStatusBarAppearanceUpdate()
    }
}

public extension UIViewController {
    var theme: ThemeBase<UIViewController> {
        get {
            if let pre = objc_getAssociatedObject(self, &kChameleonKey) as? ThemeBase<UIViewController> {
                return pre
            }
            let now = ThemeBaseViewController(owner: self)
            objc_setAssociatedObject(self, &kChameleonKey, now, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return now
        }
    }
}

@objc public extension UIView {
    func theme_awakeFromNib() {
        theme_awakeFromNib()
        theme.runWrapper(data: ThemeDataCenter.shared.currentData)
    }

    func theme_didMoveToWindow() {
        theme_didMoveToWindow()
        if let _ = window {
            theme.runWrapper(data: ThemeDataCenter.shared.currentData)
        }
    }
}

public extension ThemeBase where T: UIViewController {
    final func register() {
        ThemeServiceManager.shared.register(controller: owner)
    }
    final func defRegister() {
        ThemeServiceManager.shared.defRegister(controller: owner)
    }
}
@objc public extension UIViewController {
    func theme_awakeFromNib() {
        theme_awakeFromNib()
        theme.runWrapper(data: ThemeDataCenter.shared.currentData)
    }

    func theme_viewWillAppear(_ animated: Bool) {
        theme_viewWillAppear(animated)
        theme.runWrapper(data: ThemeDataCenter.shared.currentData)
    }
    func theme_viewDidDisappear(_ animated: Bool) {
        theme_viewDidDisappear(animated)
        theme.defRegister()
    }
}


//解析
open class ThemeHelper<T> where T: Hashable {
    public final class var current: T? {
        return ThemeDataCenter.themeData()
    }
    public final class func parse(_ data: Any?) -> T? {
        if let d = data as? ThemeDataWraper<T> {
            return d.value
        }
        return nil
    }
}

public class WeakThemeDataWraper<T: AnyObject> {
    weak var value: T?

    init(value: T) {
        self.value = value
    }
}

public class ThemeServiceManager {
    static let shared = ThemeServiceManager()

    fileprivate var viewControllers = [WeakThemeDataWraper<UIViewController>]()

    func refresh<T>(data: T) {
        let switchData = ThemeData(data: data)
        ThemeDataCenter.shared.currentData = switchData
        for window in UIApplication.shared.windows {
            window.theme.runWrapper(data: switchData)
            window.rootViewController?.view.theme.runWrapper(data: switchData)
            window.rootViewController?.theme.runWrapper(data: switchData)
        }
        for weakVC in viewControllers {
            if let vc = weakVC.value, vc.parent == nil {
                vc.view.theme.runWrapper(data: switchData)
                vc.theme.runWrapper(data: switchData)
            }
        }
    }

    fileprivate func register(controller: UIViewController) {
        func notInList() -> Bool {
            for weakVC in viewControllers {
                if weakVC.value == controller {
                    return false
                }
            }
            return true
        }
        if notInList() {
            viewControllers.append(WeakThemeDataWraper(value: controller))
        }
        print("register = \(viewControllers)")
    }

    fileprivate func defRegister(controller: UIViewController) {
        if let index = viewControllers.lastIndex(where: { (weakVC) -> Bool in
            weakVC.value == controller
        }) {
            viewControllers.removeSubrange(index ..< viewControllers.count)
//            viewControllers.remove(at: index)
        }
        print("defRegister = \(viewControllers)")
    }
}
