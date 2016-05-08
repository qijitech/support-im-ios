//
//  FailedMessageStore.h
//  Pods
//
//  Created by shuu on 16/5/6.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
@class XHMessage;

/*!
 *  失败消息的管理类，职责：
 * 新建一个表 ，保存每个对话失败的消息。(message, convid)
 * 每次进入聊天的时候，发现如果聊天连通，则把失败的消息发送出去。如果不通，则显示在列表后面。
 * 重发的时候，如果重发成功，则消除表里的记录。失败则不做操作。
 * 发送消息的时候，如果发送失败，则往失败的消息表里存一条记录。
 * 该类主要维护了两张表：
 
 表： failed_messages的结构如下：
 
 id       | conversationId | message
 -------------|----------------|-------------
 
 表：conversations的结构如下：
 
 id     |     data    | unreadCount |  mentioned
 -------------|-------------|-------------|-------------
 
 */

@interface FailedMessageStore : NSObject

/**
 *  单例
 *  @return
 */
+ (FailedMessageStore *)store;

/**
 *  openClient 时调用
 *  @param path 与 clientId 相关
 */
- (void)setupStoreWithDatabasePath:(NSString *)path;

/**
 *  发送消息失败时调用
 *  @param message 相应的消息
 */
- (void)insertFailedMessage:(AVIMTypedMessage *)message;
- (void)insertFailedXHMessage:(XHMessage *)message;
/**
 *  重发成功的时候调用
 *  @param recordId 记录的 id
 *  @return
 */
- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId;

/**
 *  查找失败的消息。进入聊天页面时调用，若聊天服务连通，则把失败的消息重发，否则，加在列表尾部。
 *  @param conversationId 对话的 id
 *  @return 消息数组
 */
- (NSArray *)selectFailedMessagesByConversationId:(NSString *)conversationId;


@end
