//
//  LZPushManager.m
//
//  Created by lzw on 15/5/25.
//  Copyright (c) 2015年 lzw. All rights reserved.
//

#import "LZPushManager.h"
#import <AVOSCloudIM/AVOSCloudIM.h>
@implementation LZPushManager

+ (LZPushManager *)manager {
    static LZPushManager *pushManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushManager = [[LZPushManager alloc] init];
    });
    return pushManager;
}

- (void)registerForRemoteNotification {
    [AVOSCloudIM registerForRemoteNotification];
}

- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    // openClient 的时候也会将 clientId 注册到 channels，这里多余了？
    if (userId) {
        [currentInstallation addUniqueObject:userId forKey:kAVIMInstallationKeyChannels];
    }
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)unsubscribeUserChannelWithBlock:(AVBooleanResultBlock)block userId:(NSString *)userId {
    if (userId) {
        [AVPush unsubscribeFromChannelInBackground:userId block:block];
    }
}

- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(AVBooleanResultBlock)block {
    AVPush *push = [[AVPush alloc] init];
    [push setChannels:userIds];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:block];
}

- (void)cleanBadge {
    UIApplication *application = [UIApplication sharedApplication];
    NSInteger num = application.applicationIconBadgeNumber;
    if (num != 0) {
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation setBadge:0];
        [currentInstallation saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
            NSLog(@"%@", error ? error : @"succeed");
        }];
        application.applicationIconBadgeNumber = 0;
    }
    [application cancelAllLocalNotifications];
}

- (void)syncBadge {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    if (currentInstallation.badge != [UIApplication sharedApplication].applicationIconBadgeNumber) {
        [currentInstallation setBadge:[UIApplication sharedApplication].applicationIconBadgeNumber];
        [currentInstallation saveEventually: ^(BOOL succeeded, NSError *error) {
            NSLog(@"%@", error ? error : @"succeed");
        }];
    } else {
//        NSLog(@"badge not changed");
    }
}

@end
