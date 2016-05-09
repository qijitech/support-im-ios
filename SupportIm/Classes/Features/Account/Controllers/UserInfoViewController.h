//
//  UserInfoViewController.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseMutipleSectionViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface UserInfoViewController : BaseMutipleSectionViewController

- (instancetype)initWithUser:(AVUser *)user;

@end
