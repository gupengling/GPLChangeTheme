//
//  ThemeKit+Extension.swift
//  ChangeSkin
//
//  Created by 顾鹏凌 on 2019/10/24.
//  Copyright © 2019 gupengling. All rights reserved.
//

import UIKit
import Foundation

extension NSObject {
    public class func overwriteInstanceMethod(originalSelector:Selector, rewriteSelector:Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, rewriteSelector)

        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))

        if didAddMethod {
            class_replaceMethod(self, rewriteSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }

    public func getCurrentMode() -> UIUserInterfaceStyle {
        let current = UITraitCollection.current.userInterfaceStyle
        return current
    }
}

@objc extension UIViewController: SkinReplaceUIProtocol {
    open func replaceTheme(now: Any, pre: Any?) {}
}

@objc extension UIView: SkinReplaceUIProtocol {
    open func replaceTheme(now: Any, pre: Any?) {}
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
//        return self.topViewController
    }
    open override var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
//        return self.topViewController
    }
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

class BaseVC: UIViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let xx = getCurrentMode()
        if xx == .light {
            print("浅色模式")
            ThemeServiceManager.shared.refresh(data: ThemeConfig.default)
        } else if xx == .dark {
            print("深色模式")
            ThemeServiceManager.shared.refresh(data: ThemeConfig.dark)
        } else {
            print("未知")
        }
    }
}
