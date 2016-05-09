//
//  FriendListViewController.m
//  Examples
//
//  Created by shuu on 16/5/9.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "FriendListViewController.h"
#import "AddFriendViewController.h"
#import "BaseNavigationController.h"
#import "NewFriendViewController.h"
#import "UserInfoTableViewCell.h"
#import "GroupViewController.h"
#import "JSBadgeView.h"
#import "Utils.h"
#import "UserManager.h"
#import "IMService.h"
#import "AVUser+Custom.h"


static NSString *kCellImageKey = @"image";
static NSString *kCellBadgeKey = @"badge";
static NSString *kCellTextKey = @"text";
static NSString *kCellSelectorKey = @"selector";

@interface FriendListViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *headerSectionDatas;

@end

@implementation FriendListViewController

#pragma mark - Life Cycle

- (instancetype)init {
    if ((self = [super init])) {
        self.title = @"联系人";
        [self refresh];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contact_IconAdd"] style:UIBarButtonItemStylePlain target:self action:@selector(goAddFriend:)];
    [self setupTableView];
    //Do this because -- Tab Bar covers TableView cells in iOS7
    self.tableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    
}

- (void)setupTableView {
    [UserInfoTableViewCell registerCellToTalbeView:self.tableView];
    [self.tableView addSubview:self.refreshControl];
}

- (UIRefreshControl *)refreshControl {
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

#pragma mark - Action

- (void)goNewFriend:(id)sender {
    NewFriendViewController *controller = [[NewFriendViewController alloc] init];
    controller.friendListViewController = self;
    [[self navigationController] pushViewController:controller animated:YES];
    self.tabBarItem.badgeValue = nil;
}

- (void)goGroup:(id)sender {
    GroupViewController *controller = [[GroupViewController alloc] init];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)goAddFriend:(id)sender {
    AddFriendViewController *controller = [[AddFriendViewController alloc] init];
    [[self navigationController] pushViewController:controller animated:YES];
}

#pragma mark - load data

- (void)refresh {
    [self refresh:nil];
}

- (void)refreshWithFriends:(NSArray *)friends badgeNumber:(NSInteger)number{
    if (number > 0) {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long)number];
    } else {
        [[self navigationController] tabBarItem].badgeValue = nil;
    }
    self.headerSectionDatas = [NSMutableArray array];
    [self.headerSectionDatas addObject:@{
                                         kCellImageKey : [UIImage imageNamed:@"plugins_FriendNotify"],
                                         kCellTextKey : @"新的朋友",kCellBadgeKey:@(number),
                                         kCellSelectorKey : NSStringFromSelector(@selector(goNewFriend:))
                                         }];
    [self.headerSectionDatas addObject:@{
                                         kCellImageKey :[UIImage imageNamed:@"add_friend_icon_addgroup"],
                                         kCellTextKey : @"群组" ,
                                         kCellSelectorKey : NSStringFromSelector(@selector(goGroup:))
                                         }];
    self.dataSource = [friends mutableCopy];
    [self.tableView reloadData];
}

- (void)findFriendsAndBadgeNumberWithBlock:(void (^)(NSArray *friends, NSInteger badgeNumber, NSError *error))block {
    [[UserManager manager] findFriendsWithBlock : ^(NSArray *objects, NSError *error) {
        // why kAVErrorInternalServer ?
        if (error && error.code != kAVErrorCacheMiss && error.code == kAVErrorInternalServer) {
            // for the first start
            block(nil, 0, error);
        } else {
            if (objects == nil) {
                objects = [NSMutableArray array];
            }
            [self countNewAddRequestBadge:^(NSInteger number, NSError *error) {
                block (objects, number, nil);
            }];
        };
    }];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self showProgress];
    [self findFriendsAndBadgeNumberWithBlock:^(NSArray *friends, NSInteger badgeNumber, NSError *error) {
        [self hideProgress];
        [Utils stopRefreshControl:refreshControl];
        if ([self filterError:error]) {
            [self refreshWithFriends:friends badgeNumber:badgeNumber];
        }
    }];
}

- (void)countNewAddRequestBadge:(AVIntegerResultBlock)block {
    [[UserManager manager] countUnreadAddRequestsWithBlock : ^(NSInteger number, NSError *error) {
        if (error) {
            block(0, nil);
        } else {
            block(number, nil);
        }
    }];
}

#pragma mark - Table view data delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.headerSectionDatas.count;
    } else {
        return self.dataSource.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @[ @"", @"" ][section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [@[ @0, @14 ][section] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoTableViewCell *cell = [UserInfoTableViewCell createOrDequeueCellByTableView:tableView];
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    static NSInteger kBadgeViewTag = 103;
    JSBadgeView *badgeView = (JSBadgeView *)[cell viewWithTag:kBadgeViewTag];
    if (badgeView) {
        [badgeView removeFromSuperview];
    }
    if (indexPath.section == 0) {
        NSDictionary *cellDatas = self.headerSectionDatas[indexPath.row];
        [cell.avatarImageView setImage:cellDatas[kCellImageKey]];
        cell.nameLabel.text = cellDatas[kCellTextKey];
        NSInteger badgeNumber = [cellDatas[kCellBadgeKey] intValue];
        if (badgeNumber > 0) {
            badgeView = [[JSBadgeView alloc] initWithParentView:cell.avatarImageView alignment:JSBadgeViewAlignmentTopRight];
            badgeView.tag = kBadgeViewTag;
            badgeView.badgeText = [NSString stringWithFormat:@"%ld", badgeNumber];
        }
    } else {
        AVUser *user = [self.dataSource objectAtIndex:indexPath.row];
        [[UserManager manager] displayAvatarOfUser:user avatarView:cell.avatarImageView];
        cell.nameLabel.text = user.displayName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        SEL selector = NSSelectorFromString(self.headerSectionDatas[indexPath.row][kCellSelectorKey]);
        [self performSelector:selector withObject:nil afterDelay:0];
    } else {
        AVUser *user = [self.dataSource objectAtIndex:indexPath.row];
        [self showProgress];
        [[IMService service] createChatRoomByUserId:user.objectId fromViewController:self completion:^(BOOL successed, NSError *error) {
            [self hideProgress];
            if (error) {
                NSLog(@"%@",error.userInfo);
            }
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"解除好友关系吗" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        alertView.tag = indexPath.row;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        AVUser *user = [self.dataSource objectAtIndex:alertView.tag];
        [self showProgress];
        [[UserManager manager] removeFriend:user callback:^(BOOL succeeded, NSError *error) {
            [self hideProgress];
            if ([self filterError:error]) {
                [self refresh];
            }
        }];
    }
}
@end
