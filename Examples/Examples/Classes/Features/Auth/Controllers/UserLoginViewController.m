//
//  UserLoginViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/27.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "UserLoginViewController.h"
#import "UserLoginView.h"
#import "UserRegisterViewController.h"
#import "MainTabBarController.h"
#import "AppDelegate.h"




@interface UserLoginViewController ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UserLoginView *userLoginView;

@end

@implementation UserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"登陆";
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;

    [self setupViews];
    [self setupBlocks];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.userLoginView.accountTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    self.userLoginView.passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPassword"];
}

- (void)setupViews {
    [self.view addSubview:self.userLoginView];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.userLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    self.userLoginView.loginButtonPressedBlock = ^(UserLoginViewButtonType type){
        if (type == UserLoginViewButtonTypeLogin) {
            if (weakSelf.userLoginView.accountTextField.text.length < 3 || weakSelf.userLoginView.passwordTextField.text.length < 3) {
                [IMToastUtil toastWithText:@"用户名或密码至少三位"];
                return;
            }
            
            //login...
            [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];

            [[UserManager manager] loginWithInput:weakSelf.userLoginView.accountTextField.text password:weakSelf.userLoginView.passwordTextField.text block:^(AVUser *user, NSError *error) {

                if (error) {
                    [IMToastUtil toastWithText:error.localizedDescription];
                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userLoginView.accountTextField.text forKey:@"userName"];
                    [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userLoginView.passwordTextField.text forKey:@"userPassword"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                    [delegate toMain];
                    
                    
//                    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
//                    [UIView transitionWithView:[[[UIApplication sharedApplication] delegate] window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//                        BOOL oldState = [UIView areAnimationsEnabled];
//                        [UIView setAnimationsEnabled:NO];
//                        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:mainTabBarController];
//                        [UIView setAnimationsEnabled:oldState];
//                    } completion:nil];
                }
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];

            }];
        }
        
        if (type == UserLoginViewButtonTypePushRegister) {
            UserRegisterViewController *registerViewController = [[UserRegisterViewController alloc] init];
//            weakSelf.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册帐号" style:UIBarButtonItemStylePlain target:nil action:nil];
            [weakSelf.navigationController pushViewController:registerViewController animated:YES];
        }
    };
}

# pragma mark - lazyload

- (UserLoginView *)userLoginView {
    if (!_userLoginView) {
        _userLoginView = [[UserLoginView alloc] init];
    }
    return _userLoginView;
}




@end
