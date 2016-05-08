//
//  LZPushManager.h
//
//  Created by lzw on 15/5/25.
//  Copyright (c) 2015年 lzw. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

static NSString *const kAVIMInstallationKeyChannels = @"channels";

@interface LZPushManager : NSObject

+ (LZPushManager *)manager;

// please call in application:didFinishLaunchingWithOptions:launchOptions
- (void)registerForRemoteNotification;

/**
 *  注销的时候使用，不再注册此用户的频道。-[AVIMClient closeWithCallback:]也会取消注册。同时用的时候，会发送请求 remove [clientId, clientId]，服务器没有返回
 */
- (void)unsubscribeUserChannelWithBlock:(AVBooleanResultBlock)block userId:(NSString *)userId;

// please call in application:didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId;

// push message
- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(AVBooleanResultBlock)block;

// please call in applicationDidBecomeActive:application
- (void)cleanBadge;

//save the local applicationIconBadgeNumber to the server
- (void)syncBadge;

@end
