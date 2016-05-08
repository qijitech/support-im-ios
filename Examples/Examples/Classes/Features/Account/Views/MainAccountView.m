//
//  MainAccountView.m
//  SupportIm
//
//  Created by shuu on 16/5/1.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "MainAccountView.h"

@interface MainAccountView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation MainAccountView

# pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = BACKGROUNDCOLOR;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

# pragma mark - private API



# pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 1 ? 4 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (!indexPath.section) {
        AVUser *user = [AVUser currentUser];
        cell.textLabel.text = user.displayName;
        [[UserManager manager] displayAvatarOfUser:user avatarView:cell.imageView];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"section-%ld row-%ld",indexPath.section,indexPath.row];
    } else {
        cell.backgroundColor = MAINCOLOR;
        cell.textLabel.text = @"退出登陆";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    UIView *lineView = [UIViewTools setLineView];
    [cell addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(cell);
        make.height.mas_equalTo(1);
    }];
    return cell;
}



# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.mainAccountViewCellSelectBlock) self.mainAccountViewCellSelectBlock(indexPath);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.f;
}

# pragma mark - lazyload




@end
