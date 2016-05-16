//
//  AVUser+Custom.h
//  SupportIm
//
//  Created by shuu on 16/4/29.
//  Copyright © 2016年 qijitech. All rights reserved.
//

//#import "AVUser.h"
#import <AVOSCloud/AVOSCloud.h>

@interface AVUser (Custom)

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) id avatarCache;

@end
