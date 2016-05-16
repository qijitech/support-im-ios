//
//  UserManager.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRequest.h"
#import "AbuseReport.h"

@interface UserManager : NSObject

+ (instancetype)manager;

- (void)loginWithInput:(NSString *)input password:(NSString *)password block:(AVUserResultBlock)block;
//- (void)loginByAuthData:(NSDictionary *)authData platform:(NSString *)platform block:(AVBooleanResultBlock)block;
- (void)registerWithUsername:(NSString *)username phone:(NSString *)phone password:(NSString *)password block:(AVBooleanResultBlock)block;
- (void)registerWithUser:(AVUser *)user block:(AVBooleanResultBlock)block;

- (void)findFriendsWithBlock:(AVArrayResultBlock)block;
- (void)findFriendsOnlyCacheWithBlock:(AVArrayResultBlock)block;
- (void)isMyFriend:(AVUser *)user block:(AVBooleanResultBlock)block;

- (void)findUsersByPartname:(NSString *)partName withBlock:(AVArrayResultBlock)block;
- (void)findUsersByIds:(NSArray *)userIds callback:(AVArrayResultBlock)callback;

- (void)getBigAvatarImageOfUser:(AVUser *)user block:(void (^)(UIImage *image))block;
- (void)displayAvatarOfUser:(AVUser *)user avatarView:(UIImageView *)avatarView;
- (void)getAvatarImageOfUser:(AVUser *)user block:(void (^)(UIImage *image))block;
- (void)updateAvatarWithImage:(UIImage *)image callback:(AVBooleanResultBlock)callback;
- (void)updateUsername:(NSString *)username block:(AVBooleanResultBlock)block;
- (void)updateUser:(AVUser *)user block:(AVBooleanResultBlock)block;

- (void)addFriend:(AVUser *)user callback:(AVBooleanResultBlock)callback;
- (void)removeFriend:(AVUser *)user callback:(AVBooleanResultBlock)callback;

- (void)countUnreadAddRequestsWithBlock:(AVIntegerResultBlock)block;
- (void)findAddRequestsWithBlock:(AVArrayResultBlock)block;
- (void)findAddRequestsOnlyCacheWithBlock:(AVArrayResultBlock)block;
- (void)agreeAddRequest:(AddRequest *)addRequest callback:(AVBooleanResultBlock)callback;
- (void)tryCreateAddRequestWithToUser:(AVUser *)user callback:(AVBooleanResultBlock)callback;
- (void)markAddRequestsAsRead:(NSArray *)addRequests block:(AVBooleanResultBlock)block;

- (void)reportAbuseWithReason:(NSString *)reason convid:(NSString *)convid block:(AVBooleanResultBlock)block;


@end
