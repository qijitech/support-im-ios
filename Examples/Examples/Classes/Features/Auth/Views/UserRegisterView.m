//
//  UserRegisterView.m
//  SupportIm
//
//  Created by shuu on 16/4/27.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "UserRegisterView.h"

@interface UserRegisterView () <UITextFieldDelegate>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIView *paddingView;

@end

@implementation UserRegisterView

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
    [self addSubview:self.registerButton];
    [self addSubview:self.accountTextField];
    [self addSubview:self.passwordTextField];
    [self addSubview:self.displayNameTextField];
    
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
        [self.displayNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordTextField.mas_bottom);
            make.left.right.height.equalTo(self.passwordTextField);
        }];
        [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.displayNameTextField.mas_bottom).with.offset(26);
            make.left.equalTo(self).with.offset(50);
            make.right.equalTo(self).with.offset(-50);
            make.height.mas_equalTo(44);
        }];
        [self.paddingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.accountTextField);
            make.bottom.equalTo(self.displayNameTextField);
            make.left.right.equalTo(self);
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
        [self registerButtonPressed];
    }
    return YES;
}

# pragma mark - private API


- (void)registerButtonPressed {
    [self endEditing:YES];
    if (self.registerButtonPressedBlock) self.registerButtonPressedBlock();
}

# pragma mark - lazyload

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIViewTools setButtonWithTitle:@"注册" titleColor:[UIColor whiteColor] fontSize:15.f backgrondColor:MAINCOLOR cornerRadius:3.f];
        [_registerButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

- (UITextField *)accountTextField {
    if (!_accountTextField) {
        _accountTextField = [UIViewTools setTextFieldWithPlaceholder:@"请输入您的帐号" placeholderColor:[UIColor lightGrayColor] placeholderFontSize:15.f contentColor:[UIColor blackColor] contentSize:15.f];
        _accountTextField.delegate = self;
        UIView *lineView = [UIViewTools setLineView];
        [_accountTextField addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.bottom.equalTo(_accountTextField);
            make.height.mas_equalTo(1);
        }];
        
    }
    return _accountTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [UIViewTools setTextFieldWithPlaceholder:@"请输入您的密码" placeholderColor:[UIColor lightGrayColor] placeholderFontSize:15.f contentColor:[UIColor blackColor] contentSize:15.f];
        _passwordTextField.delegate = self;
        UIView *lineView = [UIViewTools setLineView];
        [_passwordTextField addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.bottom.equalTo(_passwordTextField);
            make.height.mas_equalTo(1);
        }];
    }
    return _passwordTextField;
}

- (UITextField *)displayNameTextField {
    if (!_displayNameTextField) {
        _displayNameTextField = [UIViewTools setTextFieldWithPlaceholder:@"请输入您的昵称" placeholderColor:[UIColor lightGrayColor] placeholderFontSize:15.f contentColor:[UIColor blackColor] contentSize:15.f];
        _displayNameTextField.delegate = self;
    }
    return _displayNameTextField;
}

- (UIView *)paddingView {
    if (!_paddingView) {
        _paddingView = [[UIView alloc] init];
        _paddingView.backgroundColor = [UIColor whiteColor];
    }
    return _paddingView;
}

@end
