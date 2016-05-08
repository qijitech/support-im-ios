//
//  AddFriendViewController.m
//  Examples
//
//  Created by shuu on 16/5/9.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "AddFriendViewController.h"
#import "UserManager.h"
#import "BaseNavigationController.h"
#import "UserInfoViewController.h"
#import "UserInfoTableViewCell.h"
#import "Utils.h"

@interface AddFriendViewController ()

@property (nonatomic, strong) NSArray *users;

@end

static NSString *cellIndentifier = @"cellIndentifier";

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"查找好友";
    [_searchBar setDelegate:self];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self searchUser:@""];
}

- (void)searchUser:(NSString *)name {
    [[UserManager manager] findUsersByPartname:name withBlock: ^(NSArray *objects, NSError *error) {
        if ([self filterError:error]) {
            if (objects) {
                self.users = objects;
                [_tableView reloadData];
            }
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    AVUser *user = self.users[indexPath.row];
    cell.nameLabel.text = user.username;
    [[UserManager manager] displayAvatarOfUser:user avatarView:cell.avatarImageView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfoViewController *controller = [[UserInfoViewController alloc] initWithUser:self.users[indexPath.row]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *content = searchBar.text;
    [self searchUser:content];
}



@end
