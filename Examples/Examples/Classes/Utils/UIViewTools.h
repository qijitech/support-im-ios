//
//  UIViewTools.h
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewTools : NSObject

+ (UILabel *)setLabelWithText:(NSString *)text fontColor:(UIColor *)fontColor fontSize:(CGFloat)fontSize;

+ (UILabel *)setPublishedAtLabelWithTime:(NSDate *)time fontColor:(UIColor *)fontColor fontSize:(CGFloat)fontSize;

+ (UIButton *)setButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor fontSize:(CGFloat)fontSize backgrondColor:(UIColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius;

+ (UITextField *)setTextFieldWithPlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor placeholderFontSize:(CGFloat)placeholderfontSize contentColor:(UIColor *)color contentSize:(CGFloat)contentSize;

+ (UIView *)setLineView;

+ (UIImage *)roundImage:(UIImage *)image toSize:(CGSize)size radius:(float)radius;

+ (NSString *)updateTimeWithDate:(NSDate *)time;

+ (NSString *)updateTimeWithSecend:(NSInteger )time;

@end
