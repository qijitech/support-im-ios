//
//  PhoneLoginView.m
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "PhoneLoginView.h"
#import "UIViewTools.h"


@interface PhoneLoginView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIButton *nextStepButton;

@end

@implementation PhoneLoginView

# pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.nextStepButton];
    [self addSubview:self.tableView];
    
    [self updateConstraintsIfNeeded];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    [super updateConstraints];
}

# pragma mark - private API

- (void)nextStepButtonPressed {
    if (self.nextStepButtonPressedBlock)  self.nextStepButtonPressedBlock();
}

# pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.f];
    cell.textLabel.textColor = [self.dataArray[indexPath.row] isEqualToString:@"请输入您的手机号"] ? [UIColor lightGrayColor] : [UIColor blackColor];
    if (!indexPath.row) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        lineView.alpha = 0.1;
        [cell addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(cell);
            make.height.mas_equalTo(1);
        }];
    }
    return cell;
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectCellBlock) self.selectCellBlock(indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    [footerView addSubview:self.nextStepButton];
    [self.nextStepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(footerView);
        make.left.equalTo(footerView).with.offset(50);
        make.right.equalTo(footerView).with.offset(-50);
        make.height.mas_equalTo(44);
    }];
    return footerView;
}

# pragma mark - lazyload

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50.f;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = BACKGROUNDCOLOR;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"中国（＋86）",@"请输入您的手机号", nil];
    }
    return _dataArray;
}

- (UIButton *)nextStepButton {
    if (!_nextStepButton) {
        _nextStepButton = [UIViewTools setButtonWithTitle:@"下一步" titleColor:[UIColor whiteColor] fontSize:15.f backgrondColor:MAINCOLOR cornerRadius:3.f];
        [_nextStepButton addTarget:self action:@selector(nextStepButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextStepButton;
}

@end
