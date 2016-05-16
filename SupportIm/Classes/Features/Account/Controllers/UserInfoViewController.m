//
//  UserInfoViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "UserInfoViewController.h"
#import "CacheManager.h"
#import "UserManager.h"
#import "Utils.h"
#import "IMService.h"
#import "LZPushManager.h"
#import "AVUser+Custom.h"

@interface UserInfoViewController ()

@property (strong, nonatomic) AVUser *user;

@end

@implementation UserInfoViewController

- (instancetype)initWithUser:(AVUser *)user {
    self = [super init];
    if (self) {
        _user = user;
        self.tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"详情";
    [self refresh];
}

- (void)refresh {
//    [self showProgress];
    [[UserManager manager] isMyFriend : _user block : ^(BOOL isFriend, NSError *error) {
//        [self hideProgress];
        if ([self filterError:error]) {
            [[UserManager manager] getBigAvatarImageOfUser:_user block:^(UIImage *image) {
                self.dataSource =[NSMutableArray array];
                [self.dataSource addObject:@[@{kMutipleSectionImageKey:image, kMutipleSectionTitleKey:self.user.displayName}]];
                NSString *title;
                NSString *selector;
                if (isFriend) {
                    title = @"开始聊天";
                    selector = NSStringFromSelector(@selector(goChat));
                } else {
                    title = @"添加好友";
                    selector = NSStringFromSelector(@selector(tryCreateAddRequest));
                }
                [self.dataSource addObject:@[@{ kMutipleSectionTitleKey: title , kMutipleSectionSelectorKey:selector }]];
                [self.tableView reloadData];
            }];
        }
    }];
}

#pragma mark - actions

- (void)goChat {
    [[IMService service] createChatRoomByUserId:self.user.objectId fromViewController:self completion:nil];
}

- (void)tryCreateAddRequest {
    [self showProgress];
    [[UserManager manager] tryCreateAddRequestWithToUser:self.user callback: ^(BOOL succeeded, NSError *error) {
        [self hideProgress];
        if ([self filterError:error]) {
            [self showProgress];
            NSString *text = [NSString stringWithFormat:@"%@ 申请加你为好友", self.user.username];
            [[LZPushManager manager] pushMessage:text userIds:@[self.user.objectId] block:^(BOOL succeeded, NSError *error) {
                [self hideProgress];
                [self showHUDText:@"申请成功"];
            }];
        }
    }];
}


@end
