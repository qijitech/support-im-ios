//
//  PhoneLoginViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "PhoneLoginViewController.h"
#import "PhoneLoginView.h"
#import "PhoneVerifyCodeViewController.h"


@interface PhoneLoginViewController ()
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) PhoneLoginView *phoneLoginView;


@end

@implementation PhoneLoginViewController

# pragma mark - initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUNDCOLOR;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupViews];
    [self setupBlocks];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)setupViews {
    [self.view addSubview:self.phoneLoginView];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.phoneLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    self.phoneLoginView.nextStepButtonPressedBlock = ^(){
        NSString *phone = weakSelf.phoneLoginView.dataArray[1];
        if (!phone.length) {
            [IMToastUtil toastWithText:@"error phone..."];
            return ;
        }
        PhoneVerifyCodeViewController *verifyCodeViewController = [[PhoneVerifyCodeViewController alloc] initWithPhone:phone];
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"手机号登陆" style:UIBarButtonItemStylePlain target:nil action:nil];
//        weakSelf.navigationItem.backBarButtonItem = backButton;
        [weakSelf.navigationController pushViewController:verifyCodeViewController animated:YES];
    };
    self.phoneLoginView.selectCellBlock = ^(NSIndexPath *indexPath){
        if (!indexPath.row) {
            [IMToastUtil toastWithText:@"loading Country..."];
        } else {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"请输入您的手机号"
                                                                                      message:nil
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            }];
            [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            }]];
            [alertController addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                NSString *phone = [alertController.textFields[0].text mutableCopy];
                if (phone.length != 11) {
                    [IMToastUtil toastWithText:@"error phone..."];
                    return ;
                }
                [weakSelf.phoneLoginView.dataArray replaceObjectAtIndex:indexPath.row withObject:[alertController.textFields[0].text mutableCopy]];
                [weakSelf.phoneLoginView.tableView reloadData];
            }]];
            alertController.textFields[0].keyboardType = UIKeyboardTypeNumberPad;
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }
    };
    
}

# pragma mark - lazyload

- (PhoneLoginView *)phoneLoginView {
    if (!_phoneLoginView) {
        _phoneLoginView = [[PhoneLoginView alloc] init];
    }
    return _phoneLoginView;
}

@end
