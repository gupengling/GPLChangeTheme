//
//  GPLThemeManager.m
//  GPLTheme
//
//  Created by Han on 2020/8/1.
//  Copyright © 2020 GPL. All rights reserved.
//

#import "GPLThemeManager.h"
#import <UIKit/UIKit.h>

static NSString * const kDefaultThemeName = @"#ffffff";

@interface GPLThemeManager() {
    BOOL _needRemember;
}
@property (nonatomic, strong) NSMutableArray *themeBlockArray;

@end

@implementation GPLThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GPLThemeManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [GPLThemeManager sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [GPLThemeManager sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *themeLocal = [[NSUserDefaults standardUserDefaults] objectForKey:GPLThemeCofigRealyName];
        if (themeLocal != nil) {
            self.themeName = [themeLocal copy];
        } else {
            if (@available(iOS 13.0, *)) {
                if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    self.themeName = @"#000000";
                } else {
                    self.themeName = kDefaultThemeName;
                }
            } else {
                self.themeName = kDefaultThemeName;
            }
        }

        self.themeBlockArray = [NSMutableArray array];
        __weak __typeof(self) weakSelf = self;
        self.themeBlock = ^(GPLThemeChange themeBlock) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (themeBlock != nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    @synchronized (strongSelf) {
                        if (themeBlock != nil) {
                            [strongSelf.themeBlockArray addObject:themeBlock];
                        }
                    }
                });
            }
        };
        [self cleanOtherThemeConfig];
    }
    return self;
}

- (void)setNeedRemember:(BOOL)needRemember {
    _needRemember = needRemember;
    if (needRemember) {
        [[NSUserDefaults standardUserDefaults] setObject:self.themeName forKey:GPLThemeCofigRealyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:GPLThemeCofigRealyName];
    }
}

- (BOOL)needRemember {
    return _needRemember;
}

- (void)changeTheme:(id)themeName {
    [[GPLThemeManager sharedInstance] setValue:themeName forKey:GPLThemeCofigRealyName];
    [self reloadThemeConfig:YES];
    self.needRemember = _needRemember;
}

// 清除可销毁监听
- (void)cleanOtherThemeConfig {
    [self reloadThemeConfig:NO];
}

// 刷新监听配置
- (void)reloadThemeConfig:(BOOL)changeTheme {
    @synchronized (self) {
        NSMutableArray *deleteArray = [NSMutableArray array];
        for (GPLThemeChange indexBlock in self.themeBlockArray) {
            BOOL isNil = indexBlock(changeTheme);
            if (isNil) {
                [deleteArray addObject:indexBlock];
            }
        }
        [self.themeBlockArray removeObjectsInArray:deleteArray];
    }
}

@end
