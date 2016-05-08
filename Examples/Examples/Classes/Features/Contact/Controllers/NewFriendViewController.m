//
//  NewFriendViewController.m
//  Examples
//
//  Created by shuu on 16/5/9.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "NewFriendViewController.h"
#import "UserInfoViewController.h"
#import "Utils.h"
#import "AddFriendTableViewCell.h"
#import "AddRequest.h"
#import "UserManager.h"
#import <SupportIm/SupportIm.h>

@interface NewFriendViewController ()

@property (nonatomic, strong) NSArray *addRequests;

@property (nonatomic, assign) BOOL needRefreshFriendListVC;

@end

@implementation NewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"新的朋友";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self refresh:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.needRefreshFriendListVC) {
        [self.friendListViewController refresh];
    }
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self showProgress];
    WEAKSELF
    [[UserManager manager] findAddRequestsWithBlock : ^(NSArray *objects, NSError *error) {
        [self hideProgress];
        if (refreshControl) {
            [refreshControl endRefreshing];
        }
        if (error.code == kAVErrorObjectNotFound || error.code == kAVErrorCacheMiss) {
        }
        else {
            if ([self filterError:error]) {
                [self showProgress];
                [[UserManager manager] markAddRequestsAsRead:objects block:^(BOOL succeeded, NSError *error) {
                    [self hideProgress];
                    if (!error && objects.count > 0) {
                        self.needRefreshFriendListVC = YES;
                    }
                    
                    _addRequests = objects;
                    [weakSelf.tableView reloadData];
                }];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _addRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static BOOL isRegNib = NO;
    if (!isRegNib) {
//        [tableView registerNib:[UINib nibWithNibName:@"CDLabelButtonTableCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    AddFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    AddRequest *addRequest = [_addRequests objectAtIndex:indexPath.row];
    cell.nameLabel.text = addRequest.fromUser.username;
    [[UserManager manager] displayAvatarOfUser:addRequest.fromUser avatarView:cell.avatarImageView];
    if (addRequest.status == AddRequestStatusWait) {
        cell.actionButton.enabled = true;
        cell.actionButton.tag = indexPath.row;
        [cell.actionButton setTitle:@"同意" forState:UIControlStateNormal];
        [cell.actionButton addTarget:self action:@selector(actionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.actionButton.enabled = false;
        [cell.actionButton setTitle:@"已同意" forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

- (void)actionBtnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    AddRequest *addRequest = [_addRequests objectAtIndex:btn.tag];
    [self showProgress];
    [[UserManager manager] agreeAddRequest : addRequest callback : ^(BOOL succeeded, NSError *error) {
        [self hideProgress];
        if ([self filterError:error]) {
            [self showProgress];
            [[ChatManager manager] sendWelcomeMessageToOther:addRequest.fromUser.objectId text:@"我们已经是好友了，来聊天吧" block:^(BOOL succeeded, NSError *error) {
                [self hideProgress];
                [self showHUDText:@"添加成功"];
                [self refresh:nil];
            }];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AddRequest *addRequest = self.addRequests[indexPath.row];
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithUser:addRequest.fromUser];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AddRequest *addRequest = self.addRequests[indexPath.row];
        [self showProgress];
        WEAKSELF
        [addRequest deleteInBackgroundWithBlock : ^(BOOL succeeded, NSError *error) {
            [weakSelf hideProgress];
            if ([weakSelf filterError:error]) {
                [weakSelf refresh:nil];
            }
        }];
    }
}

@end
