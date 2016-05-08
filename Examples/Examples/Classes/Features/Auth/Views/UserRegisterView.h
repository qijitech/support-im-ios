//
//  UserRegisterView.h
//  SupportIm
//
//  Created by shuu on 16/4/27.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UserRegisterButtonPressedBlock)();

@interface UserRegisterView : UIView
@property (nonatomic, copy) UserRegisterButtonPressedBlock registerButtonPressedBlock;
@property (nonatomic, strong) UITextField *accountTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *displayNameTextField;

@end
