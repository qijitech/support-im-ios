//
//  AVUser+Custom.m
//  SupportIm
//
//  Created by shuu on 16/4/29.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "AVUser+Custom.h"

@implementation AVUser (Custom)

@dynamic displayName;
@dynamic avatar;
@dynamic userId;
@dynamic avatarCache;

- (NSString *)displayName {
    return [self objectForKey:@"displayName"];
}

- (void)setDisplayName:(NSString *)displayName {
    [self setObject:displayName forKey:@"displayName"];
}

- (NSString *)avatar {
    return [self objectForKey:@"avatar"];
}

- (void)setAvatar:(NSString *)avatar {
    [self setObject:avatar forKey:@"avatar"];
}

- (NSString *)userId {
    return [self objectForKey:@"userId"];
}

- (void)setUserId:(NSString *)userId {
    [self setObject:userId forKey:@"userId"];
}

- (instancetype)avatarCache {
    return [self objectForKey:@"avatarCache"];
}

- (void)setAvatarCache:(id)avatarCache {
    [self setObject:avatarCache forKey:@"avatarCache"];
}

@end
