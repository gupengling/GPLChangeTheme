//
//  Object+Extention.swift
//  GPLChangeThemeDemo
//
//  Created by 顾鹏凌 on 2020/4/24.
//  Copyright © 2020 gupengling. All rights reserved.
//

import Foundation
import UIKit

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
        var current = UIUserInterfaceStyle.light
        current = UITraitCollection.current.userInterfaceStyle
        return current
    }
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
