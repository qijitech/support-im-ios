//
//  UIViewTools.m
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "UIViewTools.h"

@implementation UIViewTools

+ (UILabel *)setLabelWithText:(NSString *)text fontColor:(UIColor *)fontColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = fontColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

+ (NSString *)updateTimeWithDate:(NSDate *)time {

    return [UIViewTools updateTimeWithSecend:(NSInteger)[time timeIntervalSince1970]];
}

+ (NSString *)updateTimeWithSecend:(NSInteger )time {
    NSString *fromPublishedTime = nil;
    NSInteger deltaTime = (NSInteger)[[NSDate date] timeIntervalSince1970] - time;
    NSInteger minites = 60;
    NSInteger hours = minites * 60;
    NSInteger days = hours * 24;
    NSInteger months = days * 30;
    NSInteger years = months * 12;
    
    if (deltaTime < hours) {
        fromPublishedTime = [NSString stringWithFormat:@"%ld分钟前",deltaTime / minites];
        if (deltaTime / minites < 1)  fromPublishedTime = @"刚刚";
    }
    else if (deltaTime < days) {
        fromPublishedTime = [NSString stringWithFormat:@"%ld小时前",deltaTime / hours];
    }
    else if (deltaTime < months) {
        fromPublishedTime = [NSString stringWithFormat:@"%ld天前",deltaTime / days];
    } else if (deltaTime < years) {
        fromPublishedTime = [NSString stringWithFormat:@"%ld月前",deltaTime / months];
    } else {
        fromPublishedTime = [NSString stringWithFormat:@"%ld年前",deltaTime / years];
    }
    return fromPublishedTime;
}


+ (UILabel *)setPublishedAtLabelWithTime:(NSDate *)time fontColor:(UIColor *)fontColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label = [[UILabel alloc] init];
    label.textColor = fontColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:fontSize];
    if (time) label.text = [UIViewTools updateTimeWithDate:time];
    return label;
}

+ (UIButton *)setButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize backgrondColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.backgroundColor = backgroundColor;
    if (cornerRadius) {
        button.layer.cornerRadius = cornerRadius;
        button.layer.masksToBounds = YES;
    }
    return button;
}

+ (UITextField *)setTextFieldWithPlaceholder:(NSString *)placeholderTitle placeholderColor:(UIColor *)placeholderColor placeholderFontSize:(CGFloat)placeholderfontSize contentColor:(UIColor *)contentColor contentSize:(CGFloat)contentSize {
    UITextField *textField = [[UITextField alloc] init];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderTitle
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName: placeholderColor,
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:placeholderfontSize],
                                                                                   }];
    textField.textColor = contentColor;
    textField.font = [UIFont systemFontOfSize:contentSize];
    textField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.spellCheckingType = UITextSpellCheckingTypeNo;
    if ([placeholderTitle rangeOfString:@"手机号"].location != NSNotFound || [placeholderTitle rangeOfString:@"验证码"].location != NSNotFound) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    if ([placeholderTitle rangeOfString:@"密码"].location != NSNotFound) {
        textField.secureTextEntry=YES;
        textField.clearsOnBeginEditing = YES;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    if ([placeholderTitle rangeOfString:@"手机号"].location == NSNotFound) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return textField;
}

+ (UIView *)setLineView {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.1;
    return lineView;
}

+ (UIImage *)roundImage:(UIImage *)image toSize:(CGSize)size radius:(float)radius {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:radius] addClip];
    [image drawInRect:rect];
    UIImage *rounded = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rounded;
}


@end
