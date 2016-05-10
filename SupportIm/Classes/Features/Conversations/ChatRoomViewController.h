//
//  ChatRoomViewController.h
//  Pods
//
//  Created by shuu on 16/5/8.
//
//

#import "XHMessageTableViewController.h"
#import "ChatManager.h"

@interface ChatRoomViewController : XHMessageTableViewController

@property (nonatomic, strong, readwrite) NSMutableArray *avimTypedMessage;
/**
 *  开放给子类，来对当前对话进行额外操作
 */
@property (nonatomic, strong, readonly) AVIMConversation *conversation;

/**
 *  当前对话的 AVIMTypedMessage Array，开放给子类来定制
 */
@property (nonatomic, strong, readonly) NSMutableArray<AVIMTypedMessage *> *msgs;

/**
 *  初始化方法
 *  @param conv 要聊天的对话
 *  @return
 */
- (instancetype)initWithConversation:(AVIMConversation *)conversation;


@end
