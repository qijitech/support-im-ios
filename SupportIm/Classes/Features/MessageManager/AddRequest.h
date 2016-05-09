//
//  AddRequest.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "AVObject.h"
#import <AVOSCloud/AVOSCloud.h>


typedef enum : NSUInteger {
    AddRequestStatusWait = 0,
    AddRequestStatusDone
} AddRequestStatus;

#define kAddRequestFromUser @"fromUser"
#define kAddRequestToUser @"toUser"
#define kAddRequestStatus @"status"
#define kAddRequestIsRead @"isRead"


@interface AddRequest : AVObject <AVSubclassing>

@property (nonatomic) AVUser *fromUser;
@property (nonatomic) AVUser *toUser;
@property (nonatomic, assign) AddRequestStatus status;
@property (nonatomic, assign) BOOL isRead; /**< 是否已读*/


@end
