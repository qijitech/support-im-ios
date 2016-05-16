//
//  PhoneVerifyCodeViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/25.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "PhoneVerifyCodeViewController.h"
#import "PhoneVerifyCodeView.h"
#import "VerifyCodeLogicModel.h"
#import "MainTabBarController.h"



@interface PhoneVerifyCodeViewController ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) PhoneVerifyCodeView *phoneVerifyCodeView;
@property (nonatomic, strong) NSString *phone;

@end

@implementation PhoneVerifyCodeViewController

# pragma mark - initialization

- (instancetype)initWithPhone:(NSString *)phone {
    if (self = [super init]) {
        self.phone = phone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupViews];
    [self setupBlocks];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)setupViews {
    [self.view addSubview:self.phoneVerifyCodeView];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.phoneVerifyCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superView);
            make.leading.mas_equalTo(superView.mas_leading);
            make.trailing.mas_equalTo(superView.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }
    [super updateViewConstraints];
}

# pragma mark - private API

- (void)setupBlocks {
    WEAKSELF
    self.phoneVerifyCodeView.nextStepButtonPressedBlock = ^(){
        NSString *code = weakSelf.phoneVerifyCodeView.dataArray[0];
        if (!code.length) {
            [IMToastUtil toastWithText:@"error code..."];
            return ;
        }
        [AVOSCloud verifySmsCode:code mobilePhoneNumber:weakSelf.phone callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
                [UIView transitionWithView:[[[UIApplication sharedApplication] delegate] window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    BOOL oldState=[UIView areAnimationsEnabled];
                    [UIView setAnimationsEnabled:NO];
                    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:mainTabBarController];
                    [UIView setAnimationsEnabled:oldState];
                } completion:nil];
            }
            if (error) {
                NSLog(@"%ld",error.code);
            }
        }];
    };
    self.phoneVerifyCodeView.selectCellBlock = ^(NSIndexPath *indexPath){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"请输入您收到的验证码"
                                                                                  message:nil
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        }];
        [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [weakSelf.phoneVerifyCodeView.dataArray replaceObjectAtIndex:indexPath.row withObject:[alertController.textFields[0].text mutableCopy]];
            [weakSelf.phoneVerifyCodeView.tableView reloadData];
        }]];
        alertController.textFields[0].keyboardType = UIKeyboardTypeNumberPad;
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    };
    self.phoneVerifyCodeView.getCodeButtonPressedBlock = ^(UIButton *button){
        [AVOSCloud requestSmsCodeWithPhoneNumber:weakSelf.phone appName:nil operation:@"注册" timeToLive:10 callback: ^(BOOL succeeded, NSError *error) {
            if (error.code == 601) {
                [AVAnalytics event:@"toast" attributes:@{@"text": @"每个号码最多一分钟一条，每天每个号码限制10条，请检查操作是否过于频繁。"}];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                //    hud.labelText=text;
                hud.detailsLabelFont = [UIFont systemFontOfSize:14];
                hud.detailsLabelText = @"每个号码最多一分钟一条，每天每个号码限制10条，请检查操作是否过于频繁。";
                hud.margin = 10.f;
                hud.removeFromSuperViewOnHide = YES;
                hud.mode = MBProgressHUDModeText;
                [hud hide:YES afterDelay:1.f];
            } else {
                NSLog(@"%ld",error.code);
            }
            if (succeeded) {
                [VerifyCodeLogicModel getCodeButtonPressed:button];
            }
        }];
    };
}

# pragma mark - lazyload

- (PhoneVerifyCodeView *)phoneVerifyCodeView {
    if (!_phoneVerifyCodeView) {
        _phoneVerifyCodeView = [[PhoneVerifyCodeView alloc] init];
    }
    return _phoneVerifyCodeView;
}

@end
