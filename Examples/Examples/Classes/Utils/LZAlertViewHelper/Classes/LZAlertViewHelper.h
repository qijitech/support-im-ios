//
//  LZAlertViewHelper.h
//  LZAlertViewHelper
//
//  Created by lzw on 15/5/26.
//  Copyright (c) 2015年 lzwjava QQ: 651142978. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for LZAlertViewHelper.
FOUNDATION_EXPORT double LZAlertViewHelperVersionNumber;

//! Project version string for LZAlertViewHelper.
FOUNDATION_EXPORT const unsigned char LZAlertViewHelperVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LZAlertViewHelper/PublicHeader.h>

typedef void(^LZAlertViewHelperFinishBlock)(BOOL confirm, NSString *text);

@interface LZAlertViewHelper : NSObject

- (void)showInputAlertViewWithMessage:(NSString *)message block:(LZAlertViewHelperFinishBlock)block;

- (void)showConfirmAlertViewWithMessage:(NSString *)message block:(LZAlertViewHelperFinishBlock)block;

- (void)showAlertViewWithMessage:(NSString *)message;

@end

