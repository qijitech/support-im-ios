//
//  AbuseReport.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "AVObject.h"
#import <AVOSCloud/AVOSCloud.h>

@interface AbuseReport : AVObject <AVSubclassing>

@property (nonatomic, strong) NSString *reason;

@property (nonatomic, strong) NSString *convid;

@property (nonatomic, strong) AVUser *author;

@end
