//
//  ConversationViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "ConversationViewController.h"
#import "Utils.h"
#import "IMService.h"

@interface ConversationViewController () <ChatListTableViewControllerDelegate>

@end

@implementation ConversationViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"消息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatListDelegate = self;
}

#pragma mark - CDChatListVCDelegate

- (void)viewController:(UIViewController *)viewController didSelectConv:(AVIMConversation *)conv {
    [[IMService service] pushToChatRoomByConversation:conv fromNavigation:viewController.navigationController completion:nil];
}

- (void)setBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount {
    if (totalUnreadCount > 0) {
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:totalUnreadCount];
    } else {
        [[self navigationController] tabBarItem].badgeValue = nil;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
}

- (UIImage *)defaultAvatarImage {
    UIImage *defaultAvatarImageView = [UIImage imageNamed:@"lcim_conversation_placeholder_avator"];
    defaultAvatarImageView = [Utils roundImage:defaultAvatarImageView toSize:CGSizeMake(100, 100) radius:5];
    return defaultAvatarImageView;
}


@end
