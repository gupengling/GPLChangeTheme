//
//  ViewController.swift
//  GPLChangeThemeDemo
//
//  Created by 顾鹏凌 on 2020/4/23.
//  Copyright © 2020 gupengling. All rights reserved.
//

import UIKit
//import AFNetworking

class ViewController: BaseAutoChangeSkinVC {
    private var btnGo = UIButton(type: .custom)
    private var btnSave = UIButton(type: .custom)

    deinit {
        print("viewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.theme.refreshThemeBlock = { [weak self] (now: Any, pre: Any?) in
            print("view now = \(now), pre = \(String(describing: pre))")
            self?.view.backgroundColor = .lightGray
            if let n = ThemeHelper<String>.parse(now) {
                if n == ThemeConfig.dark {
                    self?.view.backgroundColor = .orange
                }
            }
        }

        let v = UIView(frame: CGRect(x: 50, y: 100, width: 300, height: 200))
        view.addSubview(v)
        v.theme.refreshThemeBlock = { (now: Any, pre: Any?) in
            print("v now = \(now), pre = \(String(describing: pre))")
            v.backgroundColor = .blue
            if let n = ThemeHelper<String>.parse(now) {
                if n == ThemeConfig.dark {
                    v.backgroundColor = .red
                }
            }
        }

        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 200, width: 80, height: 50)
        btn.setTitle("Change", for: .normal)
        btn.addTarget(self, action: #selector(change(_ :)), for: .touchUpInside)
        view.addSubview(btn)
        btn.theme.refreshThemeBlock = { (now: Any, pre: Any?) in
            btn.backgroundColor = .red
            btn.setTitleColor(UIColor.yellow, for: .normal)
            if let n = ThemeHelper<String>.parse(now) {
                if n == ThemeConfig.dark {
                    btn.backgroundColor = .yellow
                    btn.setTitleColor(.red, for: .normal)
                }
            }
        }

        btnGo = UIButton(type: .custom)
        btnGo.frame = CGRect(x: 100, y: 240, width: 80, height: 50)
        btnGo.setTitle("GO", for: .normal)
        btnGo.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        view.addSubview(btnGo)

        let lable = UILabel(frame: CGRect(x: 100, y: 300, width: 100, height: 50))
        lable.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(lable)
        lable.theme.setRefreshThemeBlock {[weak self](now: Any, pre: Any?) in
            if ThemeHelper<String>.current == ThemeConfig.default {
                lable.text = "白色模式"
                lable.textColor = .red
            } else {
                lable.text = "黑色模式"
                lable.textColor = .black
            }
        }

        btnSave.frame = CGRect(x: 200, y: 500, width: 50, height: 50)
        btnSave.setTitle("save", for: .normal)
        btnSave.backgroundColor = UIColor.yellow
        btnSave.setTitleColor(UIColor.blue, for: .normal)
        btnSave.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        view.addSubview(btnSave)

    }

}
extension ViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if ThemeHelper<String>.current == ThemeConfig.default {
            return .darkContent
        } else if ThemeHelper<String>.current == ThemeConfig.dark {
            return .lightContent
        }
        return .default
    }
}

extension ViewController {
    override func replaceTheme(now: Any, pre: Any?) {
        print("switchTheme = \(now) \(String(describing: pre))")
        if ThemeHelper<String>.current == ThemeConfig.default {
            btnGo.backgroundColor = .yellow
            btnGo.setTitleColor(.blue, for: .normal)
        } else {
            btnGo.backgroundColor = .white
            btnGo.setTitleColor(UIColor.black, for: .normal)
        }
    }
}

extension ViewController {
    @objc func change(_ sender: AnyObject) {
        if ThemeHelper<String>.current == ThemeConfig.default {
            ThemeServiceManager.shared.refresh(data: ThemeConfig.dark)
        }else {
            ThemeServiceManager.shared.refresh(data: ThemeConfig.default)
        }
    }
    @objc func save(_ sender: AnyObject) {
        ThemeConfig.storeSkinTheme()
    }

    @objc func btnClicked(_ sender: Any) {
        present(ViewController(), animated: true) {

        }
    }
}
