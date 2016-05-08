//
//  SelectMemberViewController.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseTableViewController.h"
#import <SupportIm/AVIMConversation+Custom.h>

@protocol SelectMemberViewControllerDelegate <NSObject>

- (void)didSelectMember:(AVUser *)member;

@end

@interface SelectMemberViewController : BaseTableViewController

@property (nonatomic, strong) AVIMConversation *conversation;

@property id<SelectMemberViewControllerDelegate> selectMemberVCDelegate;

@end
