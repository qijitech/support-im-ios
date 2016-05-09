//
//  SelectMemberViewController.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseTableViewController.h"
#import "AVIMConversation+Custom.h"

#import <AVOSCloud/AVOSCloud.h>

@protocol SelectMemberViewControllerDelegate <NSObject>

- (void)didSelectMember:(AVUser *)member;

@end

@interface SelectMemberViewController : BaseTableViewController

@property (nonatomic, strong) AVIMConversation *conversation;

@property id<SelectMemberViewControllerDelegate> selectMemberVCDelegate;

@end
