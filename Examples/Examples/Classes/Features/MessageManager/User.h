//
//  User.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SupportIm/ChatManager.h>

/**
 *  简单的实现 CDUserModel 协议的类。可以直接在你的 User 类里实现该协议。
 */
@interface User : NSObject <UserModelDelegate>

@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *avatarUrl;


@end
