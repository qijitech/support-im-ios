//
//  GroupViewController.m
//  Examples
//
//  Created by shuu on 16/5/9.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "GroupViewController.h"
#import "IMService.h"
#import "Utils.h"
#import "UserInfoTableViewCell.h"
#import "SupportIm.h"

@interface GroupViewController ()

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"群组";
    [UserInfoTableViewCell registerCellToTalbeView:self.tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:kNotificationConversationUpdated object:nil];
    [self loadConversationsWhenInit];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationConversationUpdated object:nil];
}

- (void)loadConversationsWhenInit {
    [self showProgress];
    [[ChatManager manager] findGroupedConversationsWithBlock:^(NSArray *objects, NSError *error) {
        [self hideProgress];
        if ([self filterError:error]) {
            self.dataSource = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [[ChatManager manager] findGroupedConversationsWithNetworkFirst:YES block:^(NSArray *objects, NSError *error) {
        [Utils stopRefreshControl:refreshControl];
        if ([self filterError:error]) {
            self.dataSource = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoTableViewCell *cell = [UserInfoTableViewCell createOrDequeueCellByTableView:tableView];
    AVIMConversation *conv = [self.dataSource objectAtIndex:indexPath.row];
    cell.nameLabel.text = conv.title;
    [cell.avatarImageView setImage:conv.icon];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AVIMConversation *conv = [self.dataSource objectAtIndex:indexPath.row];
    [[IMService service] pushToChatRoomByConversation:conv fromNavigation:self.navigationController completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AVIMConversation *conv = [self.dataSource objectAtIndex:indexPath.row];
        WEAKSELF
        [conv quitWithCallback : ^(BOOL succeeded, NSError *error) {
            if ([self filterError:error]) {
                [weakSelf refresh:nil];
            }
        }];
    }
}


@end
