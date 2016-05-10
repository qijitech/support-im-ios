//
//  ChatViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "ChatViewController.h"
#import "ConversationDetailViewController.h"
#import "UserInfoViewController.h"
#import "SelectMemberViewController.h"
#import "BaseNavigationController.h"

#import "CacheManager.h"
#import "AVIMCustomMessage.h"

@interface ChatViewController () <SelectMemberViewControllerDelegate>

@end

@implementation ChatViewController

- (instancetype)initWithConversation:(AVIMConversation *)conv {
    self = [super initWithConversation:conv];
    if (self) {
        [[CacheManager manager] setCurrentConversation:conv];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contact_face_group_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goChatGroupDetail:)];
    self.navigationItem.rightBarButtonItem = item;
    //    [self testSendCustomeMessage];
}

- (void)testSendCustomeMessage {
    AVIMCustomMessage *userInfoMessage = [AVIMCustomMessage messageWithAttributes:@{ @"nickname" : @"lzw" }];
    [self.conversation sendMessage:userInfoMessage callback: ^(BOOL succeeded, NSError *error) {
        DLog(@"%@", error);
    }];
}

- (void)goChatGroupDetail:(id)sender {
    [self.navigationController pushViewController:[[ConversationDetailViewController alloc] init] animated:YES];
}

- (void)didSelectedAvatorOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    AVIMTypedMessage *msg = self.avimTypedMessage[indexPath.row];
    if ([msg.clientId isEqualToString:[ChatManager manager].clientId] == NO) {
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithUser:[[CacheManager manager] lookupUser:msg.clientId]];
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }
}

- (void)didInputAtSignOnMessageTextView:(XHMessageTextView *)messageInputTextView {
    if (self.conversation.type == ConversationTypeGroup) {
        [self performSelector:@selector(goSelectMemberVC) withObject:nil afterDelay:0];
        // weird , call below function not input @
        //        [self goSelectMemberVC];
    }
}

- (void)goSelectMemberVC {
    SelectMemberViewController *selectMemberVC = [[SelectMemberViewController alloc] init];
    selectMemberVC.selectMemberVCDelegate = self;
    selectMemberVC.conversation = self.conversation;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:selectMemberVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - CDSelectMemberVCDelegate

- (void)didSelectMember:(AVUser *)member {
    self.messageInputView.inputTextView.text = [NSString stringWithFormat:@"%@%@ ", self.messageInputView.inputTextView.text, member.displayName];
    [self performSelector:@selector(messageInputViewBecomeFristResponder) withObject:nil afterDelay:0];
}

- (void)messageInputViewBecomeFristResponder {
    [self.messageInputView.inputTextView becomeFirstResponder];
}


@end
