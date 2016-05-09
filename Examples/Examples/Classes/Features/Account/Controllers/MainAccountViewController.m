//
//  MainAccountViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/25.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "MainAccountViewController.h"
#import "MainLoginViewController.h"
#import "MainAccountView.h"
#import "PhotoGraphyPicker.h"
#import "AppDelegate.h"



@interface MainAccountViewController ()
@property (nonatomic, strong) MainAccountView *mainAccountView;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) PhotoGraphyPicker *photoGraphyPicker;



@end

@implementation MainAccountViewController

# pragma mark - initialization


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"我";
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"我" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.leftBarButtonItem.enabled = NO;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
//                                 NSFontAttributeName:[UIFont systemFontOfSize:16]
                                 };
    self.navigationController.navigationBar.titleTextAttributes = attributes;
//    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:attributes  forState:UIControlStateDisabled];
//    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:attributes  forState:UIControlStateNormal];
    
//    UIButton *button = [[UIButton alloc] init];
//    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [button setTitle:@"logout" forState:UIControlStateNormal];
//    [self.view addSubview:button];
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//        make.size.mas_equalTo(CGSizeMake(100,20));
//    }];
//    [button addTarget:self action:@selector(userLogout) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupViews];
    [self setupBlocks];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)setupViews {
    [self.view addSubview:self.mainAccountView];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.mainAccountView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.mainAccountView.mainAccountViewCellSelectBlock = ^(NSIndexPath *indexPath){
        if (!indexPath.section) {
            [weakSelf updateUserInfo];
        } else if (indexPath.section == 1) {
            [SKToastUtil toastWithText:[NSString stringWithFormat:@"section-%ld row-%ld", indexPath.section, indexPath.row]];
        } else {
            [weakSelf userLogout];
        }
    };
}

- (void)updateUserInfo {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"修改个人信息"
                                                                              message:nil
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction: [UIAlertAction actionWithTitle: @"修改昵称"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self updateDisplayName];
                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"修改头像"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
                                                           [self pickAvatar];
                                                       }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                       }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pickAvatar {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"修改个人头像"
                                                                              message:@"请选择图片来源"
                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction: [UIAlertAction actionWithTitle: @"本地相册"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self.photoGraphyPicker showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypePhotoLibrary OnViewController:self completion:^(UIImage *image) {
                                                               [self updateAvatar:image];
                                                           }];
                                                        }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"照相机"
                                                         style: UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action){
                                                           [self.photoGraphyPicker showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypeCamera OnViewController:self completion:^(UIImage *image) {
                                                               [self updateAvatar:image];
                                                           }];
                                                        }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                         style: UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *action) {
                                                       }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateAvatar:(UIImage *)avatar {
    if (!avatar) {
        return;
    }
    UIImage *rounded = [UIViewTools roundImage:avatar toSize:CGSizeMake(100, 100) radius:10];
    [[UserManager manager] updateAvatarWithImage : rounded callback : ^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self.mainAccountView reloadData];
        } else {
            [SKToastUtil toastWithText:error.localizedDescription];
        }
    }];
}

- (void)updateDisplayName {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"更改昵称"
                                                                              message:@"请填写您要修改的昵称"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *displayName = [alertController.textFields[0].text mutableCopy];
        AVUser *user = [AVUser currentUser];
        user.displayName = displayName;
        [[UserManager manager] updateUser:user block:^(BOOL succeeded, NSError *error) {
            if (!error && succeeded) {
                [self.mainAccountView reloadData];
            } else {
                [SKToastUtil toastWithText:error.localizedDescription];
            }
        }];

    }]];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)userLogout {
//    [SKToastUtil toastWithText:@"implement logout"];
    [[ChatManager manager] closeWithCallback: ^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            [AVUser logOut];
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate toLogin];

        } else {
            [SKToastUtil toastWithText:error.localizedDescription];
        }
    }];
}

#pragma mark - load data

- (MainAccountView *)mainAccountView {
    if (!_mainAccountView) {
        _mainAccountView = [[MainAccountView alloc] init];
    }
    return _mainAccountView;
}

- (PhotoGraphyPicker *)photoGraphyPicker {
    if (!_photoGraphyPicker) {
        _photoGraphyPicker = [[PhotoGraphyPicker alloc] init];
    }
    return _photoGraphyPicker;
}

@end
