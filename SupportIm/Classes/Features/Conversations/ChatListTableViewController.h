//
//  ChatListTableViewController.h
//  Pods
//
//  Created by shuu on 16/5/6.
//
//

#import <UIKit/UIKit.h>
#import "AVIMConversation+Custom.h"
#import "ConversationTableViewCell.h"

/**
 *  最近对话页面的协议
 */
@protocol ChatListTableViewControllerDelegate <NSObject>

@optional

/**
 *  来设置 tabbar 的 badge。
 *  @param totalUnreadCount 未读数总和。没有算免打扰对话的未读数。
 */
- (void)setBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount;

/**
 *  点击了某对话。此时可跳转到聊天页面
 *  @param viewController 最近对话 controller
 *  @param conv           点击的对话
 */
- (void)viewController:(UIViewController *)viewController didSelectConv:(AVIMConversation *)conv;

/**
 *  额外配置 Cell。将在 tableView:cellForRowAtIndexPath 最后调用
 *  @param cell
 *  @param indexPath
 *  @param conversation 相应的对话
 */
- (void)configureCell:(ConversationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withConversation:(AVIMConversation *)conversation;

- (void)prepareConversationsWhenLoad:(NSArray *)conversations completion:(AVIMBooleanResultBlock)completion;

- (UIImage *)defaultAvatarImage;

@end

/**
 *  最近对话页面
 */
@interface ChatListTableViewController : UITableViewController

/**
 *  设置 delegate
 */
@property (nonatomic, strong) id<ChatListTableViewControllerDelegate> chatListDelegate;


@end
