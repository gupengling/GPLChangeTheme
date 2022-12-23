//
//  NSObject+GPLUpdate.m
//  GPLTheme
//
//  Created by Han on 2020/8/1.
//  Copyright © 2020 GPL. All rights reserved.
//

#import "NSObject+GPLUpdate.h"
#import <objc/runtime.h>

@interface NSObject ()
@property (nonatomic, assign) BOOL initThemeCofig;
@end

@implementation NSObject (GPLUpdate)

- (BOOL)initThemeCofig {
    @synchronized (self) {
        return  (BOOL)objc_getAssociatedObject(self, _cmd);
    }
}

- (void)setInitThemeCofig:(BOOL)initThemeCofig {
    @synchronized (self) {
        objc_setAssociatedObject(self, @selector(initThemeCofig), @(initThemeCofig), OBJC_ASSOCIATION_ASSIGN);
    }
}

- (GPLThemeChangeBlock)themeChangeBlock {
    @synchronized (self) {
        return objc_getAssociatedObject(self, _cmd);
    }
}

- (void)runThemeChangeBlock {
    __weak typeof(self) weakself = self;
    void (^runBlock)(void) = ^{
        __strong typeof(weakself) strongSelf = weakself;
        if (strongSelf.themeChangeBlock) {
            strongSelf.themeChangeBlock(strongSelf, [strongSelf realyThemeName]);
        }
        [strongSelf setThemeConfigBlock];
    };
    
    if ([NSThread currentThread].isMainThread) {
        runBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            runBlock();
        });
    }
}
- (id)realyThemeName {
    id theme = [GPLThemeManager.sharedInstance valueForKey:GPLThemeCofigRealyName];
    return theme;
}

- (void)setThemeChangeBlock:(GPLThemeChangeBlock)themeChangeBlock {
    @synchronized (self) {
        objc_setAssociatedObject(self, @selector(themeChangeBlock), themeChangeBlock, OBJC_ASSOCIATION_COPY);
        [self runThemeChangeBlock];
    }
}

- (void)setThemeConfigBlock {
    if (!self.initThemeCofig) {
        self.initThemeCofig = YES;
        __weak typeof(self) weakSelf = self;
        [GPLThemeManager sharedInstance].themeBlock(^BOOL(BOOL themeChange) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (themeChange && strongSelf) {
                if (strongSelf.themeChangeBlock) {
                    [strongSelf runThemeChangeBlock];
                }
            }
            return strongSelf ? NO : YES;
        });
    }
}
@end
