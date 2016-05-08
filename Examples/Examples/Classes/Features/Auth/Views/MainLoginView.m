//
//  MainLoginView.m
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "MainLoginView.h"
#import "UIViewTools.h"
//#import "BEMCheckBox.h"


@interface MainLoginView ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) UIButton *wechatLoginButton;
@property (nonatomic, strong) UIButton *phoneLoginButton;
//@property (nonatomic, strong) BEMCheckBox *checkButton;
@property (nonatomic, strong) UILabel *agreementLabel;
@property (nonatomic, strong) UIButton *agreementButton;

@end

@implementation MainLoginView

# pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.logoImageView];
    [self addSubview:self.logoLabel];
    [self addSubview:self.wechatLoginButton];
    [self addSubview:self.phoneLoginButton];
//    [self addSubview:self.checkButton];
    [self addSubview:self.agreementLabel];
    [self addSubview:self.agreementButton];

    [self updateConstraintsIfNeeded];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 80));
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.logoLabel.mas_top).with.offset(-10);
        }];
        [self.logoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 20));
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_centerY).with.offset(-50);
        }];
        [self.wechatLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(45);
            make.left.equalTo(self).with.offset(50);
            make.right.equalTo(self).with.offset(-50);
            make.bottom.equalTo(self.phoneLoginButton.mas_top).with.offset(-30);
        }];
        [self.phoneLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(65, 20));
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.agreementButton.mas_top).with.offset(-40);
        }];
//        [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(12, 12));
//            make.bottom.equalTo(self).with.offset(-70);
//            make.right.equalTo(self.agreementLabel.mas_left).with.offset(-5);
//        }];
        [self.agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(65, 12));
//            make.centerY.equalTo(self.checkButton);
            make.bottom.equalTo(self).with.offset(-70);
            make.right.equalTo(self.mas_centerX).with.offset(-5);
        }];
        [self.agreementButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(90, 12));
            make.centerY.equalTo(self.agreementLabel);
            make.left.equalTo(self.agreementLabel.mas_right);
        }];
    }
    [super updateConstraints];
}

# pragma mark - private API

- (void)mainLoginButtonPressed:(UIButton *)button {
    if (self.buttonPressedBlock) self.buttonPressedBlock((MainLoginButtonType)button.tag);
}

# pragma mark - lazyload

- (UIImageView *)logoImageView {
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.backgroundColor = MAINCOLOR;
        _logoImageView.layer.cornerRadius = 6.f;
        _logoImageView.layer.masksToBounds = YES;
    }
    return _logoImageView;
}

- (UILabel *)logoLabel {
    if (!_logoLabel) {
        _logoLabel = [UIViewTools setLabelWithText:@"航城科技" fontColor:[UIColor darkGrayColor] fontSize:17.f];
    }
    return _logoLabel;
}

- (UIButton *)wechatLoginButton {
    if (!_wechatLoginButton) {
        _wechatLoginButton = [UIViewTools setButtonWithTitle:@"账号登陆" titleColor:[UIColor whiteColor] fontSize:17.f backgrondColor:MAINCOLOR cornerRadius:3.f];
        _wechatLoginButton.tag = MainLoginButtonTypeWechat;
        [_wechatLoginButton addTarget:self action:@selector(mainLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wechatLoginButton;
}

- (UIButton *)phoneLoginButton {
    if (!_phoneLoginButton) {
        _phoneLoginButton = [UIViewTools setButtonWithTitle:@"手机号登陆" titleColor:MAINCOLOR fontSize:12.f backgrondColor:nil cornerRadius:0.f];
        _phoneLoginButton.tag = MainLoginButtonTypePhone;
        [_phoneLoginButton addTarget:self action:@selector(mainLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneLoginButton;
}

//- (BEMCheckBox *)checkButton {
//    if (!_checkButton) {
//        _checkButton = [[BEMCheckBox alloc] init];
//        _checkButton.boxType = BEMBoxTypeCircle;
//        _checkButton.onAnimationType = BEMAnimationTypeBounce;
//        _checkButton.offAnimationType = BEMAnimationTypeBounce;
//        _checkButton.onTintColor = [UIColor grayColor];
//        _checkButton.onCheckColor = [UIColor grayColor];
//        _checkButton.lineWidth = 1.f;
//
//    }
//    return _checkButton;
//}

- (UILabel *)agreementLabel {
    if (!_agreementLabel) {
        _agreementLabel = [UIViewTools setLabelWithText:@"已阅读并同意" fontColor:[UIColor grayColor] fontSize:10.f];
    }
    return _agreementLabel;
}

- (UIButton *)agreementButton {
    if (!_agreementButton) {
        _agreementButton = [UIViewTools setButtonWithTitle:nil titleColor:nil fontSize:10.f backgrondColor:nil cornerRadius:0.f];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"软件许可及服务协议"];
        NSRange titleRange = {0,[title length]};
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:titleRange];
        [_agreementButton setAttributedTitle:title forState:UIControlStateNormal];
        _agreementButton.tag = MainLoginButtonTypeAgreement;
        [_agreementButton addTarget:self action:@selector(mainLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreementButton;
}


@end
