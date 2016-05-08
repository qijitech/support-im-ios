//
//  MainLoginView.h
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef enum {
    MainLoginButtonTypeWechat = 1,
    MainLoginButtonTypePhone = 2,
    MainLoginButtonTypeAgreement = 3,
} MainLoginButtonType;

typedef void(^MainLoginViewBlock)(MainLoginButtonType type);

@interface MainLoginView : UIView
@property (nonatomic, copy) MainLoginViewBlock buttonPressedBlock;

@end
