//
//  VerifyCodeLogicModel.m
//  SupportIm
//
//  Created by shuu on 16/4/25.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "VerifyCodeLogicModel.h"

static NSInteger const kVerifyCodeTotalTime = 300;
static NSString * const kButtonTitle = @"获取验证码";
static NSString * const kButtonPressedTitle = @"已发送(%@)";
static BOOL kVerifyCode = NO;

@interface VerifyCodeLogicModel ()

@end

@implementation VerifyCodeLogicModel

+ (void)getCodeButtonPressed:(UIButton *)button {
    kVerifyCode = NO;
    [[VerifyCodeLogicModel alloc] startTimeWithButton:button];
}

- (void)startTimeWithButton:(UIButton *)button {
    if (kVerifyCode) return;
    __block int timeout = kVerifyCodeTotalTime - 1;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if (timeout <= 0){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (button.titleLabel.font != [UIFont systemFontOfSize:15]) {
                    button.titleLabel.font = [UIFont systemFontOfSize:15];
                    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                }
                [button setTitle:kButtonTitle forState:UIControlStateNormal];
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                kVerifyCode = NO;
            });
        }else{
            int seconds = timeout % kVerifyCodeTotalTime ;
            NSString *time = [NSString stringWithFormat:@"%d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                if (button.titleLabel.font != [UIFont systemFontOfSize:15]) {
                    button.titleLabel.font = [UIFont systemFontOfSize:15];
                    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                }
                [button setTitle:[NSString stringWithFormat:kButtonPressedTitle, time] forState:UIControlStateNormal];
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [UIView commitAnimations];
                kVerifyCode = YES;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

@end
