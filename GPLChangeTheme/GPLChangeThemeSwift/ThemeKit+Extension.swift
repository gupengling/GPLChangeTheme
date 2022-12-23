//
//  ThemeKit+Extension.swift
//  ChangeSkin
//
//  Created by 顾鹏凌 on 2019/10/24.
//  Copyright © 2019 gupengling. All rights reserved.
//

import UIKit
import Foundation

@objc extension UIViewController: SkinReplaceUIProtocol {
    open func replaceTheme(now: Any, pre: Any?) {}
}

@objc extension UIView: SkinReplaceUIProtocol {
    open func replaceTheme(now: Any, pre: Any?) {}
}

class BaseAutoChangeSkinVC: UIViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let xx = getCurrentMode()
        if xx == UIUserInterfaceStyle.light {
            print("浅色模式")
            ThemeServiceManager.shared.refresh(data: ThemeConfig.default)
        } else if xx == UIUserInterfaceStyle.dark {
            print("深色模式")
            ThemeServiceManager.shared.refresh(data: ThemeConfig.dark)
        } else {
            print("未知")
        }
    }
}
