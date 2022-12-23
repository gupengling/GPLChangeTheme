//
//  NSObject+GPLUpdate.h
//  GPLTheme
//
//  Created by Han on 2020/8/1.
//  Copyright © 2020 GPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPLThemeManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^GPLThemeChangeBlock) (id _Nullable object, NSString * _Nullable theme);

@interface NSObject (GPLUpdate)

@property (nonnull, nonatomic, copy) GPLThemeChangeBlock themeChangeBlock;

- (id)realyThemeName;

@end

NS_ASSUME_NONNULL_END
