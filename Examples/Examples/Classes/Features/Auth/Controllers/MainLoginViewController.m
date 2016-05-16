//
//  MainLoginViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "MainLoginViewController.h"
#import "MainLoginView.h"
#import "PhoneLoginViewController.h"
#import "UserLoginViewController.h"



@interface MainLoginViewController ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) MainLoginView *mainLoginView;

@end

@implementation MainLoginViewController

# pragma mark - initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupViews];
    [self setupBlocks];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)setupViews {
    [self.view addSubview:self.mainLoginView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.mainLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.mainLoginView.buttonPressedBlock = ^(MainLoginButtonType type){
        if (type == MainLoginButtonTypeWechat) {
            UserLoginViewController *userLoginViewController = [[UserLoginViewController alloc] init];
//            weakSelf.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"账号登陆" style:UIBarButtonItemStylePlain target:nil action:nil];
            [weakSelf.navigationController pushViewController:userLoginViewController animated:YES];
        } else if (type == MainLoginButtonTypePhone) {
            PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] init];
//            weakSelf.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"手机号登陆" style:UIBarButtonItemStylePlain target:nil action:nil];
            [weakSelf.navigationController pushViewController:phoneLoginViewController animated:YES];
        } else {
            [IMToastUtil toastWithText:@"Agreement"];
        }
    };
}

# pragma mark - lazyload

- (MainLoginView *)mainLoginView {
    if (!_mainLoginView) {
        _mainLoginView = [[MainLoginView alloc] init];
    }
    return _mainLoginView;
}

@end
