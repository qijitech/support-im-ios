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
#import "JSBadgeView.h"
#import <Masonry/Masonry.h>
#import "ContactIndexModel.h"

static NSString *kCellImageKey = @"image";
static NSString *kCellBadgeKey = @"badge";
static NSString *kCellTextKey = @"text";
static NSString *kCellSelectorKey = @"selector";
static NSString *const kNotificationFriendListNeedRefresh = @"FriendListNeedRefresh";


@interface FriendListViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *headerSectionDatas;
@property (nonatomic, strong) NSMutableArray *indexArray;
@property (nonatomic, strong) NSMutableArray *indexTitleArray;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kNotificationFriendListNeedRefresh object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTableView {
    [UserInfoTableViewCell registerCellToTalbeView:self.tableView];
    [self.tableView addSubview:self.refreshControl];
}



- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
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
    if (self.dataSource.count) [self sortDataSourceWithIndex];
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

#pragma mark - contact index 

- (NSMutableArray *)indexArray {
    if (!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (NSMutableArray *)indexTitleArray {
    if (!_indexTitleArray) {
        _indexTitleArray = [NSMutableArray array];
    }
    return _indexTitleArray;
}

- (NSString *)stringWithSpell:(NSString *)string {
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformStripDiacritics, NO);
    //    NSMutableString *removedBlankString = [mutableString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return mutableString;
}

// i'm so diao, i'm heheda ,been here.
- (void)sortDataSourceWithIndex {

    NSMutableArray *displayNameSortArray = [NSMutableArray array];
    NSMutableSet *indexSet = [NSMutableSet set];
    NSMutableArray *indexArray = [NSMutableArray array];
    
    [self.dataSource enumerateObjectsUsingBlock:^(AVUser *user, NSUInteger idx, BOOL * _Nonnull stop) {
        ContactIndexModel *model = [[ContactIndexModel alloc] init];
        model.displayName = user.displayName;
        model.index = idx;
        model.fullSpelling = [self stringWithSpell:user.displayName];
        model.indexSpelling = [model.fullSpelling substringWithRange:NSMakeRange(0, 1)];
        [displayNameSortArray addObject:model];
        [indexSet addObject:model.indexSpelling];
        NSLog(@"%ld--%@--%@",model.index,model.indexSpelling,model.fullSpelling);
    }];
    
    indexArray = [[indexSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    indexArray = [NSMutableArray arrayWithArray:indexArray];
    
    NSMutableArray *sortArray = [NSMutableArray array];
    [indexArray enumerateObjectsUsingBlock:^(NSString *indexSpelling, NSUInteger section, BOOL * _Nonnull stop) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [displayNameSortArray enumerateObjectsUsingBlock:^(ContactIndexModel *model, NSUInteger index, BOOL * _Nonnull stop) {
            if ([model.indexSpelling isEqualToString:indexSpelling]) {
                model.index = index;
                model.section = section;
                [sectionArray addObject:model];
            }
        }];
        [sortArray addObject:sectionArray];
    }];

    [sortArray enumerateObjectsUsingBlock:^(NSMutableArray *sectionArray, NSUInteger section, BOOL * _Nonnull stop) {
        sectionArray = [sectionArray sortedArrayUsingComparator:^NSComparisonResult(ContactIndexModel *model1, ContactIndexModel *model2) {
            return [model1.fullSpelling compare:model2.fullSpelling options:NSCaseInsensitiveSearch];
        }];
    }];
    
 
    NSScanner *scan = [NSScanner scannerWithString:indexArray[0]];
    int val;
    if ([scan scanInt:&val]) {
        [sortArray addObject:sortArray.firstObject];
        [sortArray removeObjectAtIndex:0];
        [indexArray addObject:indexArray.firstObject];
        [indexArray removeObjectAtIndex:0];
    }
                       
    self.indexArray = sortArray;
    self.indexTitleArray = indexArray;
    
    NSLog(@"%s",__func__);
    
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    self.tableView.sectionIndexColor = [UIColor darkGrayColor];
    return self.indexTitleArray;
}

#pragma mark - Table view data delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.headerSectionDatas.count;
    } else if (section == self.indexArray.count) {
        return [self.indexArray[section - 1] count] + 1;
    } else {
        return [self.indexArray[section - 1] count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexArray.count + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section ? [self.indexArray[section - 1][0] indexSpelling] : nil;
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
            cell.avatarImageView.clipsToBounds = NO;
            badgeView.tag = kBadgeViewTag;
            badgeView.badgeText = [NSString stringWithFormat:@"%ld", badgeNumber];
        }
    } else {
        if (indexPath.section == self.indexArray.count && indexPath.row == [self.indexArray[indexPath.section - 1] count]) {
            cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = [NSString stringWithFormat:@"%ld位联系人", self.indexArray.count];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        } else {
            NSInteger index = [self.indexArray[indexPath.section - 1][indexPath.row] index];
            AVUser *user = self.dataSource[index];
            [[UserManager manager] displayAvatarOfUser:user avatarView:cell.avatarImageView];
            cell.nameLabel.text = user.displayName;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        SEL selector = NSSelectorFromString(self.headerSectionDatas[indexPath.row][kCellSelectorKey]);
        [self performSelector:selector withObject:nil afterDelay:0];
    } else {
        NSInteger index = [self.indexArray[indexPath.section - 1][indexPath.row] index];
        AVUser *user = self.dataSource[index];
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
