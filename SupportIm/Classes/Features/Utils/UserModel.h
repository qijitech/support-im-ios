//
//  UserModel.h
//  Pods
//
//  Created by shuu on 16/5/6.
//
//

#import <Foundation/Foundation.h>

/**
 *  聊天的 User Model 协议
 */
@protocol UserModelDelegate <NSObject>

@required

/**
 *  用户的 id，如果你的用户系统是数字，则可转换成字符串 @"123"
 *  @return
 */
- (NSString *)userId;

/**
 *  头像的 url，在最近对话页面和聊天页面使用，会结合缓存来用
 *  @return
 */
- (NSString *)avatarUrl;

/**
 *  用户名
 *  @return
 */
- (NSString *)username;

@end
