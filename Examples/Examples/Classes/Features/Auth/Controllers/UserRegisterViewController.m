//
//  UserRegisterViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/27.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "UserRegisterViewController.h"
#import "UserRegisterView.h"

static  NSString * const kAvatar = @"http://img1.imgtn.bdimg.com/it/u=1248462995,728310824&fm=21&gp=0.jpg";

@interface UserRegisterViewController ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UserRegisterView *userRegisterView;

@end

@implementation UserRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = @"注册";
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    [self setupViews];
    [self setupBlocks];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupViews {
    [self.view addSubview:self.userRegisterView];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.userRegisterView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.userRegisterView.registerButtonPressedBlock = ^(){
        if (weakSelf.userRegisterView.accountTextField.text.length < 3 || weakSelf.userRegisterView.passwordTextField.text.length < 3) {
            [SKToastUtil toastWithText:@"用户名或密码至少三位"];
            return;
        }
        
       // register
        AVUser *user = [AVUser user];
        user.username = weakSelf.userRegisterView.accountTextField.text;
        user.password = weakSelf.userRegisterView.passwordTextField.text;
        user.displayName = weakSelf.userRegisterView.displayNameTextField.text;
        user.avatar = kAvatar;
        user.userId = [weakSelf ramdomUserId];


        
        
        [[UserManager manager] registerWithUser:user block:^(BOOL succeeded, NSError *error) {
            if (error) {
                [SKToastUtil toastWithText:error.localizedDescription];
            }
            else {
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userRegisterView.accountTextField.text forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults] setObject:weakSelf.userRegisterView.passwordTextField.text forKey:@"userPassword"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    };
}

- (NSString *)ramdomUserId {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return uuid;
}

# pragma mark - lazyload

- (UserRegisterView *)userRegisterView {
    if (!_userRegisterView) {
        _userRegisterView = [[UserRegisterView alloc] init];
    }
    return _userRegisterView;
}




@end
