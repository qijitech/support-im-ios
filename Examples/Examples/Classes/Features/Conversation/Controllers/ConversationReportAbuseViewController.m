//
//  ConversationReportAbuseViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "ConversationReportAbuseViewController.h"
#import "UserManager.h"
#import "Utils.h"

static CGFloat kCDConvReportAbuseVCHorizontalPadding = 10;
static CGFloat kCDConvReportAbuseVCVerticalPadding = 10;
static CGFloat kCDConvReportAbuseVCInputTextFieldHeight = 100;

@interface ConversationReportAbuseViewController ()

@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong) NSString *convid;

@end

@implementation ConversationReportAbuseViewController

- (instancetype)initWithConversationId:(NSString *)convid {
    self = [super init];
    if (self) {
        _convid = convid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"举报";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    [self.view addSubview:self.inputTextField];
}

- (UITextField *)inputTextField {
    if (_inputTextField == nil) {
        _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(kCDConvReportAbuseVCHorizontalPadding, kCDConvReportAbuseVCVerticalPadding, CGRectGetWidth(self.view.frame) - 2 * kCDConvReportAbuseVCHorizontalPadding, kCDConvReportAbuseVCInputTextFieldHeight)];
        _inputTextField.borderStyle = UITextBorderStyleRoundedRect;
//        _inputTextField.horizontalPadding = kTextFieldCommonHorizontalPadding;
//        _inputTextField.verticalPadding = kTextFieldCommonVerticalPadding;
        _inputTextField.placeholder = @"请输入举报原因";
    }
    return _inputTextField;
}

- (void)submit:(id)sender {
    if (self.inputTextField.text.length > 0) {
        WEAKSELF
        NSLog(@"%@", self.inputTextField.text);
        [self showProgress];
        [[UserManager manager] reportAbuseWithReason:self.inputTextField.text convid:self.convid block: ^(BOOL succeeded, NSError *error) {
            [weakSelf hideProgress];
            if ([self filterError:error]) {
                [self alert:@"感谢您的举报，我们将尽快处理。"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
