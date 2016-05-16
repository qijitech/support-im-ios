//
// Created by 杨玉刚 on 3/24/16.
//

#import <Foundation/Foundation.h>
#import <MaterialControls/MDToast.h>

@interface IMToastUtil : NSObject

+ (void)toastWithText:(NSString *)text;

+ (void)toastWithText:(NSString *)text duration:(double)duration;

@end