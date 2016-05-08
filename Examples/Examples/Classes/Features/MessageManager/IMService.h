//
//  IMService.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SupportIm/ChatManager.h>
#import "BaseViewController.h"

typedef void (^CompletionBlock)(BOOL successed, NSError *error);

@interface IMService : NSObject <UserDelegate>

+ (instancetype)service;

/*!
 @brief  create conversation room, if success push to it
 */
- (void)createChatRoomByUserId:(NSString *)userId fromViewController:(BaseViewController *)viewController completion:(CompletionBlock)completion;

/*!
 @brief  firstly, create conversation room, secondly, if success, push to it.
 */
- (void)pushToChatRoomByConversation:(AVIMConversation *)conversation fromNavigation:(UINavigationController *)navigation completion:(CompletionBlock)completion;

@end
