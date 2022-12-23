# GPLChangeTheme
change skin solution
Welcome to the GPLChangeTheme wiki!

#swift的使用方式

## Podfile
```
pod 'GPLChangeTheme/Swift', :git => 'https://github.com/gupengling/GPLChangeTheme.git'
pod install
```
## 项目中调用

启动
```
ThemeConfig.restoreSkinTheme()
print("application = \(String(describing: ThemeHelper<String>.current))")
```

```
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
```
```
override var preferredStatusBarStyle: UIStatusBarStyle {
        if ThemeHelper<String>.current == ThemeConfig.default {
            return .darkContent
        } else if ThemeHelper<String>.current == ThemeConfig.dark {
            return .lightContent
        }
        return .default
    }
```
```
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
```
```
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
```

#oc的使用方式
```
        GPLThemeManager.sharedInstance().needRemember = true
        GPLThemeManager.sharedInstance().themeChangeBlock = { object, theme in
            WDLog("config theme = \(String(describing: object)) \(String(describing: theme))")
        }
        WDLog("当前皮肤 \(GPLThemeManager.sharedInstance().themeName)")
```
```
- (void)dealloc {
    [GPLThemeManager.sharedInstance cleanOtherThemeConfig];
}
```
```
 __weak __typeof(self) weakSelf = self;
        self.themeChangeBlock = ^(id _Nullable object, NSString * _Nullable theme) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([theme isEqualToString:@"#ffffff"]) {
                strongSelf.view.backgroundColor = [UIColor whiteColor];
                [btn setBackgroundColor:[UIColor darkGrayColor]];
            } else {
                strongSelf.view.backgroundColor = [UIColor blackColor];
                [btn setBackgroundColor:[UIColor lightGrayColor]];
            }
        };
```
```
 WDAlertTipsAction *defaultAction = [[WDAlertTipsAction alloc] initWithTitle:@"黑"
                                                                          style:(WDAlertTipsActionStyleDefault)
                                                                        handler:^(WDAlertTipsAction * _Nullable action) {
        NSLog(@"action = %@", action.title);
        [[GPLThemeManager sharedInstance] changeTheme:@"#000000"];

    }];
    defaultAction.enabled = [[self realyThemeName] isEqualToString:@"#ffffff"];
    [vc addAction:defaultAction];
```
