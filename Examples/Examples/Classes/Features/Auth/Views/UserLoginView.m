//
//  UserLoginView.m
//  SupportIm
//
//  Created by shuu on 16/4/27.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "UserLoginView.h"

@interface UserLoginView () <UITextFieldDelegate>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIView *paddingView;
@property (nonatomic, strong) UIButton *pushRegisterButton;


@end

@implementation UserLoginView

# pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
        self.backgroundColor = BACKGROUNDCOLOR;
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.paddingView];
    [self addSubview:self.loginButton];
    [self addSubview:self.accountTextField];
    [self addSubview:self.passwordTextField];
    [self addSubview:self.pushRegisterButton];

    [self updateConstraintsIfNeeded];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self.accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(30);
            make.left.equalTo(self).with.offset(20);
            make.right.equalTo(self).with.offset(-20);
            make.height.mas_equalTo(50);
        }];
        [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.accountTextField.mas_bottom);
            make.left.right.height.equalTo(self.accountTextField);
        }];
        [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordTextField.mas_bottom).with.offset(26);
            make.left.equalTo(self).with.offset(50);
            make.right.equalTo(self).with.offset(-50);
            make.height.mas_equalTo(44);
        }];
        [self.paddingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.accountTextField);
            make.bottom.equalTo(self.passwordTextField);
            make.left.right.equalTo(self);
        }];
        [self.pushRegisterButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-50);
            make.size.mas_equalTo(CGSizeMake(80, 20));
            make.top.equalTo(self.loginButton.mas_bottom).with.offset(20);
        }];
    }
    [super updateConstraints];
}

# pragma mark - UITextFieldDelegate

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordTextField) {
        [self userLoginViewButtonPressed:self.loginButton];
    }
    return YES;
}

# pragma mark - private API

- (void)userLoginViewButtonPressed:(UIButton *)button {
    [self endEditing:YES];
    if (self.loginButtonPressedBlock)  self.loginButtonPressedBlock((UserLoginViewButtonType)button.tag);
}



# pragma mark - lazyload

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIViewTools setButtonWithTitle:@"登陆" titleColor:[UIColor whiteColor] fontSize:15.f backgrondColor:MAINCOLOR cornerRadius:3.f];
        [_loginButton addTarget:self action:@selector(userLoginViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.tag = UserLoginViewButtonTypeLogin;
    }
    return _loginButton;
}

- (UITextField *)accountTextField {
    if (!_accountTextField) {
        _accountTextField = [UIViewTools setTextFieldWithPlaceholder:@"请输入您的帐号" placeholderColor:[UIColor lightGrayColor] placeholderFontSize:15.f contentColor:[UIColor blackColor] contentSize:15.f];
        _accountTextField.delegate = self;
        
    }
    return _accountTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [UIViewTools setTextFieldWithPlaceholder:@"请输入您的密码" placeholderColor:[UIColor lightGrayColor] placeholderFontSize:15.f contentColor:[UIColor blackColor] contentSize:15.f];
        _passwordTextField.delegate = self;
    }
    return _passwordTextField;
}

- (UIView *)paddingView {
    if (!_paddingView) {
        _paddingView = [[UIView alloc] init];
        _paddingView.backgroundColor = [UIColor whiteColor];
        UIView *lineView = [UIViewTools setLineView];
        [_paddingView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.centerY.equalTo(_paddingView);
            make.height.mas_equalTo(1);
        }];
    }
    return _paddingView;
}

- (UIButton *)pushRegisterButton {
    if (!_pushRegisterButton) {
        _pushRegisterButton = [UIViewTools setButtonWithTitle:@"没有帐号？去注册" titleColor:[UIColor darkGrayColor] fontSize:10.f backgrondColor:nil cornerRadius:2.f];
        [_pushRegisterButton addTarget:self action:@selector(userLoginViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _pushRegisterButton.tag = UserLoginViewButtonTypePushRegister;
    }
    return _pushRegisterButton;
}

@end

