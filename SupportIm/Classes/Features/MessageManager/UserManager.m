//
//  UserManager.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "UserManager.h"
#import "Utils.h"
#import "CacheManager.h"
#import "AbuseReport.h"
#import "UIImage+Icon.h"
#import <AVOSCloud/AVOSCloud.h>
#import "AVUser+Custom.h"

#define KEY_USERNAME @"KEY_USERNAME"


static UIImage *defaultAvatar;

static UserManager *userManager;

@interface UserManager()

@end

@implementation UserManager

+ (instancetype)manager {
    static dispatch_once_t token ;
    dispatch_once(&token, ^{
        userManager = [[UserManager alloc] init];
    });
    return userManager;
}

#pragma mark - login

//- (void)loginByAuthData:(NSDictionary *)authData platform:(NSString *)platform block:(AVBooleanResultBlock)block {
//    __block NSString *username = authData[@"username"];
//    __block NSString *avatar = authData[@"avatar"];
//    [AVUser loginWithAuthData:authData platform:platform block:^(AVUser *user, NSError *error) {
//        if (error) {
//            block(NO, error);
//        } else {
//            if (user.updatedAt) {
//                // 之前已经登录过、设置好用户名和头像了
//                block(YES, nil);
//            } else {
//                if (username) {
//                    [self countUserByUsername:username block:^(NSInteger number, NSError *error) {
//                        if (error) {
//                            block(NO, error);
//                        } else {
//                            if (number > 0) {
//                                // 用户名重复了，给一个随机的后缀
//                                username = [NSString stringWithFormat:@"%@%@",username, [[Utils uuid] substringToIndex:3]];
//                                [self changeToUsername:username avatar:avatar user:user block:block];
//                            } else {
//                                [self changeToUsername:username avatar:avatar user:user block:block];
//                            }
//                        }
//                    }];
//                } else {
//                    // 应该不可能出现这种情况
//                    // 没有名字，只改头像
//                    [self changeToUsername:nil avatar:avatar user:user block:block];
//                }
//            }
//        }
//    }];
//}

- (void)changeToUsername:(NSString *)username avatar:(NSString *)avatar user:(AVUser *)user block:(AVBooleanResultBlock)block{
    [self uploadAvatarWithUrl:avatar block:^(AVFile *file, NSError *error) {
        if (file) {
            [user setObject:file forKey:@"avatar"];
        }
        if (username) {
            user.username = username;
        }
        [user saveInBackgroundWithBlock:block];
    }];
}


- (void)uploadAvatarWithUrl:(NSString *)url block:(AVFileResultBlock)block {
    if (!url) {
        block(nil, nil);
    } else {
        AVFile *file = [AVFile fileWithURL:url];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                block(nil, error);
            } else {
                block(file, nil);
            }
        }];
    }
}

- (void)countUserByUsername:(NSString *)username block:(AVIntegerResultBlock)block {
    AVQuery *q = [AVUser query];
    [q whereKey:@"username" equalTo:username];
    [q countObjectsInBackgroundWithBlock:block];
}

- (void)loginWithInput:(NSString *)input password:(NSString *)password block:(AVUserResultBlock)block {
    if ([Utils isPhoneNumber:input]) {
        [AVUser logInWithMobilePhoneNumberInBackground:input password:password block:block];
    } else {
        [AVUser logInWithUsernameInBackground:input password:password block:block];
    }
}

- (void)registerWithUsername:(NSString *)username phone:(NSString *)phone password:(NSString *)password block:(AVBooleanResultBlock)block {
    AVUser *user = [AVUser user];
    user.username = username;
    user.password = password;
    if (phone) {
        user.mobilePhoneNumber = phone;
    }
    [user setFetchWhenSave:YES];
    [user signUpInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (error) {
            block(NO, error);
        } else {
            if (phone) {
                [[NSUserDefaults standardUserDefaults] setObject:phone forKey:KEY_USERNAME];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:KEY_USERNAME];
            }
            block(YES, nil);
        }
    }];
}

- (void)registerWithUser:(AVUser *)user block:(AVBooleanResultBlock)block {
    [user setFetchWhenSave:YES];
    [user signUpInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (error) {
            block(NO, error);
        } else {

            [[NSUserDefaults standardUserDefaults] setObject:user.username forKey:KEY_USERNAME];

            block(YES, nil);
        }
    }];
}

#pragma mark -

- (void)findFriendsWithBlock:(AVArrayResultBlock)block {
    AVUser *user = [AVUser currentUser];
    AVQuery *q = [user followeeQuery];
    q.cachePolicy = kAVCachePolicyNetworkElseCache;
    [q findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (error == nil) {
            [[CacheManager manager] registerUsers:objects];
        }
        block(objects, error);
    }];
}

- (void)isMyFriend:(AVUser *)user block:(AVBooleanResultBlock)block {
    AVUser *currentUser = [AVUser currentUser];
    AVQuery *q = [currentUser followeeQuery];
    //TODO:Why nil?
    NSString *reason = [NSString stringWithFormat:@"\n\n------ BEGIN LOG ------\nclass name :%@\nline: %@\nreason:%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"AVUser is nil"];
    NSAssert(user, reason);
    [q whereKey:@"followee" equalTo:user];
    [q findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (error) {
            block(NO, error);
        } else {
            if (objects.count > 0) {
                block(YES, nil);
            } else {
                block(NO, error);
            }
        }
    }];
}

- (void)findUsersByPartname:(NSString *)partName withBlock:(AVArrayResultBlock)block {
    AVQuery *q = [AVUser query];
    [q setCachePolicy:kAVCachePolicyNetworkElseCache];
    [q whereKey:@"displayName" containsString:partName];
    AVUser *curUser = [AVUser currentUser];
    [q whereKey:@"objectId" notEqualTo:curUser.objectId];
    [q orderByDescending:@"updatedAt"];
    [q findObjectsInBackgroundWithBlock:block];
}

- (void)findUsersByIds:(NSArray *)userIds callback:(AVArrayResultBlock)callback {
    if ([userIds count] > 0) {
        AVQuery *q = [AVUser query];
        [q setCachePolicy:kAVCachePolicyNetworkElseCache];
        [q whereKey:@"objectId" containedIn:userIds];
        [q findObjectsInBackgroundWithBlock:callback];
    } else {
        callback([[NSArray alloc] init], nil);
    }
}

- (void)displayAvatarOfUser:(AVUser *)user avatarView:(UIImageView *)avatarView {
    [self getAvatarImageOfUser:user block: ^(UIImage *image) {
        [avatarView setImage:image];
    }];
}

- (void)getBigAvatarImageOfUser:(AVUser *)user block:(void (^)(UIImage *image))block {
    CGFloat avatarWidth = 60;
    CGSize avatarSize = CGSizeMake(avatarWidth, avatarWidth);
    [[UserManager manager] getAvatarImageOfUser:user block: ^(UIImage *image) {
        UIImage *resizedImage = [Utils resizeImage:image toSize:avatarSize];
        block(resizedImage);
    }];
}

- (void)getAvatarImageOfUser:(AVUser *)user block:(void (^)(UIImage *image))block {
//    AVFile *avatar = [user objectForKey:@"avatar"];
    AVFile *avatar = [AVFile fileWithURL:user.avatar];
    if (avatar) {
        [avatar getDataInBackgroundWithBlock: ^(NSData *data, NSError *error) {
            if (error == nil) {
                block([UIImage imageWithData:data]);
            } else {
                block([self defaultAvatarOfUser:user]);
            }
        }];
    } else {
        block([self defaultAvatarOfUser:user]);
    }
}

- (UIImage *)defaultAvatarOfUser:(AVUser *)user {
    return [UIImage imageWithHashString:user.objectId displayString:[[user.username substringWithRange:NSMakeRange(0, 1)] capitalizedString]];
}

- (void)updateAvatarWithImage:(UIImage *)image callback:(AVBooleanResultBlock)callback {
    NSData *data = UIImagePNGRepresentation(image);
    AVFile *file = [AVFile fileWithData:data];
    [file saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
        if (error) {
            callback(succeeded, error);
        } else {
            AVUser *user = [AVUser currentUser];
            [user setObject:file forKey:@"avatar"];
            [user saveInBackgroundWithBlock:callback];
        }
    }];
}

- (void)updateUsername:(NSString *)username block:(AVBooleanResultBlock)block{
    AVUser *user = [AVUser currentUser];
    user.username = username;
    [user saveInBackgroundWithBlock:block];
}

- (void)updateUser:(AVUser *)user block:(AVBooleanResultBlock)block {
    [user saveInBackgroundWithBlock:block];
}

- (void)addFriend:(AVUser *)user callback:(AVBooleanResultBlock)callback {
    AVUser *curUser = [AVUser currentUser];
    [curUser follow:user.objectId andCallback:callback];
}

- (void)removeFriend:(AVUser *)user callback:(AVBooleanResultBlock)callback {
    AVUser *curUser = [AVUser currentUser];
    [curUser unfollow:user.objectId andCallback:callback];
}

#pragma mark - AddRequest

- (void)findAddRequestsWithBlock:(AVArrayResultBlock)block {
    AVUser *curUser = [AVUser currentUser];
    AVQuery *q = [AddRequest query];
    [q includeKey:kAddRequestFromUser];
    [q whereKey:kAddRequestToUser equalTo:curUser];
    [q orderByDescending:@"createdAt"];
    [q findObjectsInBackgroundWithBlock:block];
}

- (void)countUnreadAddRequestsWithBlock:(AVIntegerResultBlock)block {
    AVQuery *q = [AddRequest query];
    AVUser *user = [AVUser currentUser];
    [q whereKey:kAddRequestToUser equalTo:user];
    [q whereKey:kAddRequestIsRead equalTo:@NO];
    [q setCachePolicy:kAVCachePolicyNetworkElseCache];
    [q countObjectsInBackgroundWithBlock:block];
}

- (void)agreeAddRequest:(AddRequest *)addRequest callback:(AVBooleanResultBlock)callback {
    [[UserManager manager] addFriend:addRequest.fromUser callback: ^(BOOL succeeded, NSError *error) {
        if (error) {
            if (error.code != kAVErrorDuplicateValue) {
                callback(NO, error);
            } else {
                addRequest.status = AddRequestStatusDone;
                [addRequest saveInBackgroundWithBlock:callback];
            }
        } else {
            addRequest.status = AddRequestStatusDone;
            [addRequest saveInBackgroundWithBlock:callback];
        }
    }];
}

- (void)haveWaitAddRequestWithToUser:(AVUser *)toUser callback:(AVBooleanResultBlock)callback {
    AVUser *user = [AVUser currentUser];
    AVQuery *q = [AddRequest query];
    [q whereKey:kAddRequestFromUser equalTo:user];
    [q whereKey:kAddRequestToUser equalTo:toUser];
    [q whereKey:kAddRequestStatus equalTo:@(AddRequestStatusWait)];
    [q countObjectsInBackgroundWithBlock: ^(NSInteger number, NSError *error) {
        if (error) {
            if (error.code == kAVErrorObjectNotFound) {
                callback(NO, nil);
            } else {
                callback(NO, error);
            }
        } else {
            if (number > 0) {
                callback(YES, error);
            } else {
                callback(NO, error);
            }
        }
    }];
}

- (void)markAddRequestsAsRead:(NSArray *)addRequests block:(AVBooleanResultBlock)block {
    for (AddRequest *addReqeust in addRequests) {
        if (addReqeust.isRead == NO) {
            addReqeust.isRead = YES;
        }
    }
    [AVObject saveAllInBackground:addRequests block:block];
}

- (void)tryCreateAddRequestWithToUser:(AVUser *)user callback:(AVBooleanResultBlock)callback {
    [self haveWaitAddRequestWithToUser:user callback: ^(BOOL succeeded, NSError *error) {
        if (error) {
            callback(NO, error);
        } else {
//            if (succeeded) {
//                callback(YES, [NSError errorWithDomain:@"Add Request" code:0 userInfo:@{ NSLocalizedDescriptionKey:@"已经请求过了" }]);
//            } else {
                AVUser *curUser = [AVUser currentUser];
                AddRequest *addRequest = [[AddRequest alloc] init];
                addRequest.fromUser = curUser;
                addRequest.toUser = user;
                addRequest.isRead = NO;
                addRequest.status = AddRequestStatusWait;
                [addRequest saveInBackgroundWithBlock:callback];
//            }
        }
    }];
}

#pragma mark - report abuse

- (void)reportAbuseWithReason:(NSString *)reason convid:(NSString *)convid block:(AVBooleanResultBlock)block {
    AbuseReport *report = [[AbuseReport alloc] init];
    report.reason = reason;
    report.convid = convid;
    report.author = [AVUser currentUser];
    [report saveInBackgroundWithBlock:block];
}

@end
