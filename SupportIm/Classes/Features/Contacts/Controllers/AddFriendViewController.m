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
#import "AVUser+Custom.h"
#import <Masonry/Masonry.h>

@interface AddFriendViewController ()
@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) NSArray *users;

@end

static NSString *cellIndentifier = @"cellIndentifier";

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"查找好友";
    [self setupViews];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)setupViews {
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        
        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.height.mas_equalTo(44);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom);
            make.right.left.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
    [super updateViewConstraints];
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
    UserInfoTableViewCell *cell = [UserInfoTableViewCell createOrDequeueCellByTableView:tableView];
    AVUser *user = self.users[indexPath.row];
    cell.nameLabel.text = user.displayName;
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

# pragma mark - lazyload 

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}


@end
