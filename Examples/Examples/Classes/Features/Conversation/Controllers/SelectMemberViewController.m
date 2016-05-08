//
//  SelectMemberViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "SelectMemberViewController.h"
#import "UserManager.h"
#import "CacheManager.h"
#import "ChatManager.h"
#import "UserInfoTableViewCell.h"

@interface SelectMemberViewController ()


@end

@implementation SelectMemberViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewControllerStyle = ViewControllerStylePresenting;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"选择要提醒的人";
    [UserInfoTableViewCell registerCellToTalbeView:self.tableView];
    [self loadDataSource];
}

- (void)loadDataSource {
    NSMutableSet *userIds = [NSMutableSet setWithArray:self.conversation.members];
    [userIds removeObject:[ChatManager manager].clientId];
    [self showProgress];
    [[CacheManager manager] cacheUsersWithIds:userIds callback:^(BOOL succeeded, NSError *error) {
        [self hideProgress];
        if ([self filterError:error]) {
            self.dataSource  = [[userIds allObjects] mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoTableViewCell *cell = [UserInfoTableViewCell createOrDequeueCellByTableView:tableView];
    NSString *userId = [self.dataSource objectAtIndex:indexPath.row];
    AVUser *user = [[CacheManager manager] lookupUser:userId];
    [[UserManager manager] displayAvatarOfUser:user avatarView:cell.avatarImageView];
    cell.nameLabel.text = user.username;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *userId = [self.dataSource objectAtIndex:indexPath.row];
    AVUser *user = [[CacheManager manager] lookupUser:userId];
    if([self.selectMemberVCDelegate respondsToSelector:@selector(didSelectMember:)]) {
        [self.selectMemberVCDelegate didSelectMember:user];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
