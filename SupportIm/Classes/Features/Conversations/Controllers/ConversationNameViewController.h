//
//  ConversationNameViewController.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ConversationDetailViewController.h"
#import "ChatManager.h"

@interface ConversationNameViewController : BaseTableViewController

@property (nonatomic, strong) ConversationDetailViewController *detailVC;
@property (nonatomic, strong) AVIMConversation *conv;

@end
