//
//  UserLoginView.h
//  SupportIm
//
//  Created by shuu on 16/4/27.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UserLoginViewButtonTypeLogin = 1,
    UserLoginViewButtonTypePushRegister
} UserLoginViewButtonType;
typedef void(^UserLoginButtonPressedBlock)(UserLoginViewButtonType type);

@interface UserLoginView : UIView
@property (nonatomic, copy) UserLoginButtonPressedBlock loginButtonPressedBlock;
@property (nonatomic, assign) UserLoginViewButtonType type;
@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@end
