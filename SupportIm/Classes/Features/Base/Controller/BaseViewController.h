//
//  BaseViewController.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

typedef enum : NSInteger {
    ViewControllerStylePlain = 0,
    ViewControllerStylePresenting
}ViewControllerStyle;


@interface BaseViewController : UIViewController

@property (nonatomic, assign) ViewControllerStyle viewControllerStyle;

- (void)showNetworkIndicator;

- (void)hideNetworkIndicator;

- (void)showProgress;

- (void)hideProgress;

- (void)alert:(NSString *)msg;

- (BOOL)alertError:(NSError *)error;

- (BOOL)filterError:(NSError *)error;

- (void)runInMainQueue:(void (^)())queue;

- (void)runInGlobalQueue:(void (^)())queue;

- (void)runAfterSecs:(float)secs block:(void (^)())block;

- (void)showHUDText:(NSString *)text;

- (void)toast:(NSString *)text;

- (void)toast:(NSString *)text duration:(NSTimeInterval)duration;


@end
