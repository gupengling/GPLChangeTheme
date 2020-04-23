//
//  Theme_Protocol.swift
//  ChangeSkin
//
//  Created by 顾鹏凌 on 2019/10/24.
//  Copyright © 2019 gupengling. All rights reserved.
//

import UIKit

public typealias RefreshThemeBlock = ((_ now: Any, _ pre: Any?) -> Void)

public protocol SkinReplaceUIProtocol: class {
    func replaceTheme(now: Any, pre: Any?)
}

protocol SkinReplaceProtocol: class {
    var data: ThemeData? {get set}

    var refreshThemeBlock: RefreshThemeBlock? {get set}

    var callback: SkinReplaceUIProtocol {get}

    var childrens: [SkinReplaceProtocol] {get}

    func before()

    func after()
}

extension SkinReplaceProtocol {
    func setRefreshThemeBlock(block: @escaping RefreshThemeBlock) {
        refreshThemeBlock = block
    }
}
