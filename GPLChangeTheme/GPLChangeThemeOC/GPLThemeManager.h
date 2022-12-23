//
//  GPLThemeManager.h
//  GPLTheme
//
//  Created by Han on 2020/8/1.
//  Copyright © 2020 GPL. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define WeakSelf(type)  __weak typeof(type) weak##type = type;
//#define StrongSelf(type)  __strong typeof(type) strong##type = weak##type;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^GPLThemeChange)(BOOL themeChange);
static NSString * const GPLThemeCofigRealyName = @"themeName";

@interface GPLThemeManager : NSObject
@property (nonatomic, assign) BOOL needRemember;
@property (nonatomic, assign, readwrite) NSString *themeName;
@property (nonatomic, copy, readwrite) void (^themeBlock)(GPLThemeChange themeBlock);

+ (instancetype)sharedInstance;

- (void)changeTheme:(id)themeName;

/* 清除可销毁监听 **/
- (void)cleanOtherThemeConfig;
@end

NS_ASSUME_NONNULL_END
