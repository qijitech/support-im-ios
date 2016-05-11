//
//  ChatManager.m
//  Pods
//
//  Created by shuu on 16/5/6.
//
//

#import "ChatManager.h"
#import "SoundManager.h"
#import "ConversationStore.h"
#import "FailedMessageStore.h"
#import "ChatManager_Internal.h"
#import <AVOSCloud/AVOSCloud.h>
#import "EmotionUtils.h"

static ChatManager *instance;

@interface ChatManager () <AVIMClientDelegate, AVIMSignatureDataSource>

@property (nonatomic, assign, readwrite) BOOL connect;
@property (nonatomic, strong) NSMutableDictionary *cachedConversations;
@property (nonatomic, strong) NSString *plistPath;
@property (nonatomic, strong) NSMutableDictionary *conversationDatas;
@property (nonatomic, assign) NSInteger totalUnreadCount;

@end


@implementation ChatManager

#pragma mark - lifecycle

+ (instancetype)manager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[ChatManager alloc] init];
    });
    return instance;
}

+ (instancetype)sharedManager {
    return [self manager];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [AVIMClient setTimeoutIntervalInSeconds:300];
        // 以下选项也即是说 A 不在线时，有人往A发了很多条消息，下次启动时，不再收到具体的离线消息，而是收到离线消息的数目(未读通知)
        //         [AVIMClient setUserOptions:@{AVIMUserOptionUseUnread:@(YES)}];
        _cachedConversations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)databasePathWithUserId:(NSString *)userId{
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [libPath stringByAppendingPathComponent:[NSString stringWithFormat:@"com.leancloud.leanchatlib.%@.db3", userId]];
}

- (void)openWithClientId:(NSString *)clientId callback:(AVIMBooleanResultBlock)callback {
    _clientId = clientId;
    NSString *dbPath = [self databasePathWithUserId:_clientId];
    [[ConversationStore store] setupStoreWithDatabasePath:dbPath];
    [[FailedMessageStore store] setupStoreWithDatabasePath:dbPath];
    self.client = [[AVIMClient alloc] initWithClientId:clientId];
    self.client.delegate = self;
    /* 取消下面的注释，将对 im的 open ，start(create conv),kick,invite 操作签名，更安全
     可以从你的服务器获得签名，这里从云代码获取，需要部署云代码，https://github.com/leancloud/leanchat-cloudcode
     */
    // self.client.signatureDataSource = self;
    [self.client openWithCallback:^(BOOL succeeded, NSError *error) {
        [self updateConnectStatus];
        if (callback) {
            callback(succeeded, error);
        }
        //        [CDEmotionUtils saveEmotions];
    }];
}

- (void)openWithCallback:(AVIMBooleanResultBlock)callback {
    _clientId = [AVUser currentUser].objectId;
    NSString *dbPath = [self databasePathWithUserId:_clientId];
    [[ConversationStore store] setupStoreWithDatabasePath:dbPath];
    [[FailedMessageStore store] setupStoreWithDatabasePath:dbPath];
    self.client = [[AVIMClient alloc] initWithClientId:_clientId];
    self.client.delegate = self;
    /* 取消下面的注释，将对 im的 open ，start(create conv),kick,invite 操作签名，更安全
     可以从你的服务器获得签名，这里从云代码获取，需要部署云代码，https://github.com/leancloud/leanchat-cloudcode
     */
    // self.client.signatureDataSource = self;
    [self.client openWithCallback:^(BOOL succeeded, NSError *error) {
        [self updateConnectStatus];
        if (callback) {
            callback(succeeded, error);
        }
        //        [CDEmotionUtils saveEmotions];
    }];
}

- (void)closeWithCallback:(AVBooleanResultBlock)callback {
    [self.client closeWithCallback:callback];
}

#pragma mark - conversation

- (void)fecthConversationWithConversationId:(NSString *)conversationId callback:(AVIMConversationResultBlock)callback {
    NSAssert(conversationId.length > 0, @"Conversation id is nil");
    AVIMConversationQuery *q = [self.client conversationQuery];
    q.cachePolicy = kAVCachePolicyNetworkElseCache;
    [q whereKey:@"objectId" equalTo:conversationId];
    [q findConversationsWithCallback: ^(NSArray *objects, NSError *error) {
        if (error) {
            callback(nil, error);
        } else {
            if (objects.count == 0) {
                callback(nil, [ChatManager errorWithText:[NSString stringWithFormat:@"conversation of %@ not exists", conversationId]]);
            } else {
                callback([objects objectAtIndex:0], error);
            }
        }
    }];
}

- (void)checkDuplicateValueOfArray:(NSArray *)array {
    NSSet *set = [NSSet setWithArray:array];
    if (set.count != array.count) {
        [NSException raise:NSInvalidArgumentException format:@"The array has duplicate value"];
    }
}

- (void)fetchConversationWithMembers:(NSArray *)members type:(ConversationType)type callback:(AVIMConversationResultBlock)callback {
    if ([members containsObject:self.clientId] == NO) {
        [NSException raise:NSInvalidArgumentException format:@"members should contain myself"];
    }
    [self checkDuplicateValueOfArray:members];
    [self createConversationWithMembers:members type:type unique:YES callback:callback];
}

- (void)fetchConversationWithMembers:(NSArray *)members callback:(AVIMConversationResultBlock)callback {
    [self fetchConversationWithMembers:members type:ConversationTypeGroup callback:callback];
}

- (void)fetchConversationWithOtherId:(NSString *)otherId callback:(AVIMConversationResultBlock)callback {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:self.client.clientId];
    [array addObject:otherId];
    [self fetchConversationWithMembers:array type:ConversationTypeSingle callback:callback];
}

- (void)createConversationWithMembers:(NSArray *)members type:(ConversationType)type unique:(BOOL)unique callback:(AVIMConversationResultBlock)callback {
    NSString *name = nil;
    if (type == ConversationTypeGroup) {
        // 群聊默认名字， 老王、小李
        name = [AVIMConversation nameOfUserIds:members];
    }
    AVIMConversationOption options;
    if (unique) {
        // 如果相同 members 的对话已经存在，将返回原来的对话
        options = AVIMConversationOptionUnique;
    } else {
        // 创建一个新对话
        options = AVIMConversationOptionNone;
    }
    [self.client createConversationWithName:name clientIds:members attributes:@{ CONVERSATION_TYPE:@(type) } options:options callback:callback];
}

- (void)createConversationWithMembers:(NSArray *)members type:(ConversationType)type callback:(AVIMConversationResultBlock)callback {
    [self createConversationWithMembers:members type:type unique:NO callback:callback];
}

- (void)findGroupedConversationsWithBlock:(AVIMArrayResultBlock)block {
    [self findGroupedConversationsWithNetworkFirst:NO block:block];
}

- (void)findGroupedConversationsWithNetworkFirst:(BOOL)networkFirst block:(AVIMArrayResultBlock)block {
    AVIMConversationQuery *q = [self.client conversationQuery];
    [q whereKey:AVIMAttr(CONVERSATION_TYPE) equalTo:@(ConversationTypeGroup)];
    [q whereKey:kAVIMKeyMember containedIn:@[self.clientId]];
    if (networkFirst) {
        q.cachePolicy = kAVCachePolicyNetworkElseCache;
    } else {
        q.cachePolicy = kAVCachePolicyCacheElseNetwork;
        q.cacheMaxAge = 60 * 30; // 半小时
    }
    // 默认 limit 为10
    q.limit = 1000;
    [q findConversationsWithCallback:block];
}

- (void)updateConversation:(AVIMConversation *)conversation name:(NSString *)name attrs:(NSDictionary *)attrs callback:(AVIMBooleanResultBlock)callback {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (name) {
        [dict setObject:name forKey:@"name"];
    }
    if (attrs) {
        [dict setObject:attrs forKey:@"attrs"];
    }
    [conversation update:dict callback:callback];
}

- (void)fetchConversationsWithConversationIds:(NSSet *)conversationIds callback:(AVIMArrayResultBlock)callback {
    if (conversationIds.count > 0) {
        AVIMConversationQuery *q = [self.client conversationQuery];
        [q whereKey:@"objectId" containedIn:[conversationIds allObjects]];
        q.cachePolicy = kAVCachePolicyNetworkElseCache;
        q.limit = 1000;  // default limit:10
        [q findConversationsWithCallback:callback];
    } else {
        callback([NSMutableArray array], nil);
    }
}

#pragma mark - utils

- (void)sendMessage:(AVIMTypedMessage*)message conversation:(AVIMConversation *)conversation callback:(AVBooleanResultBlock)block {
    id<UserModelDelegate> selfUser = [[ChatManager manager].userDelegate getUserById:self.clientId];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    // 云代码中获取到用户名，来设置推送消息, 老王:今晚约吗？
    if (selfUser.username) {
        // 避免为空造成崩溃
        [attributes setObject:selfUser.username forKey:@"username"];
    }
    if (self.useDevPushCerticate) {
        [attributes setObject:@YES forKey:@"dev"];
    }
    if (message.attributes == nil) {
        message.attributes = attributes;
    } else {
        [attributes addEntriesFromDictionary:message.attributes];
        message.attributes = attributes;
    }
    [conversation sendMessage:message options:AVIMMessageSendOptionRequestReceipt callback:block];
}

- (void)sendWelcomeMessageToOther:(NSString *)other text:(NSString *)text block:(AVBooleanResultBlock)block {
    [self fetchConversationWithOtherId:other callback:^(AVIMConversation *conversation, NSError *error) {
        if (error) {
            block(NO, error);
        } else {
            AVIMTextMessage *textMessage = [AVIMTextMessage messageWithText:text attributes:nil];
            [self sendMessage:textMessage conversation:conversation callback:block];
        }
    }];
}

#pragma mark - query msgs

- (void)queryTypedMessagesWithConversation:(AVIMConversation *)conversation timestamp:(int64_t)timestamp limit:(NSInteger)limit block:(AVIMArrayResultBlock)block {
    AVIMArrayResultBlock callback = ^(NSArray *messages, NSError *error) {
        //以下过滤为了避免非法的消息，引起崩溃
        NSMutableArray *typedMessages = [NSMutableArray array];
        for (AVIMTypedMessage *message in messages) {
            if ([message isKindOfClass:[AVIMTypedMessage class]]) {
                [typedMessages addObject:message];
            }
        }
        block(typedMessages, error);
    };
    if(timestamp == 0) {
        // sdk 会设置好 timestamp
        [conversation queryMessagesWithLimit:limit callback:callback];
    } else {
        [conversation queryMessagesBeforeId:nil timestamp:timestamp limit:limit callback:callback];
    }
}

#pragma mark - remote notification

- (BOOL)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo[@"convid"]) {
        self.remoteNotificationConvid = userInfo[@"convid"];
        return YES;
    }
    return NO;
}

#pragma mark - AVIMClientDelegate

- (void)imClientPaused:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

- (void)imClientResuming:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

- (void)imClientResumed:(AVIMClient *)imClient {
    [self updateConnectStatus];
}

#pragma mark - status

// 除了 sdk 的上面三个回调调用了，还在 open client 的时候调用了，好统一处理
- (void)updateConnectStatus {
    self.connect = self.client.status == AVIMClientStatusOpened;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectivityUpdated object:@(self.connect)];
}

#pragma mark - receive message handle

- (void)receiveMessage:(AVIMTypedMessage *)message conversation:(AVIMConversation *)conversation{
    [[ConversationStore store] insertConversation:conversation];
    if (![self.chattingConversationId isEqualToString:conversation.conversationId]) {
        // 没有在聊天的时候才增加未读数和设置mentioned
        [[ConversationStore store] increaseUnreadCountWithConversation:conversation];
        if ([self isMentionedByMessage:message]) {
            [[ConversationStore store] updateMentioned:YES conversation:conversation];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUnreadsUpdated object:nil];
    }
    if (!self.chattingConversationId) {
        if (!conversation.muted) {
            [[SoundManager manager] playLoudReceiveSoundIfNeed];
            [[SoundManager manager] vibrateIfNeed];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageReceived object:message];
}

#pragma mark - AVIMMessageDelegate

// content : "this is message"
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    // 不做处理，此应用没有用到
    // 可以看做跟 AVIMTypedMessage 两个频道。构造消息和收消息的接口都不一样，互不干扰。
    // 其实一般不用，有特殊的需求时可以考虑优先用 自定义 AVIMTypedMessage 来实现。见 AVIMCustomMessage 类
}

// content : "{\"_lctype\":-1,\"_lctext\":\"sdfdf\"}"  sdk 会解析好
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    if (message.messageId) {
        if (conversation.creator == nil && [[ConversationStore store] isConversationExists:conversation] == NO) {
            [conversation fetchWithCallback:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                } else {
                    [self receiveMessage:message conversation:conversation];
                }
            }];
        } else {
            [self receiveMessage:message conversation:conversation];
        }
    } else {
        NSLog(@"Receive Message , but MessageId is nil");
    }
}

- (void)conversation:(AVIMConversation *)conversation messageDelivered:(AVIMMessage *)message {
    NSLog(@"%s",__func__);
    if (message != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageDelivered object:message];
    }
}

- (void)conversation:(AVIMConversation *)conversation didReceiveUnread:(NSInteger)unread {
    // 需要开启 AVIMUserOptionUseUnread 选项，见 init
    NSLog(@"conversatoin:%@ didReceiveUnread:%@", conversation, @(unread));
    [conversation markAsReadInBackground];
}

#pragma mark - AVIMClientDelegate

- (void)conversation:(AVIMConversation *)conversation membersAdded:(NSArray *)clientIds byClientId:(NSString *)clientId {
    NSLog(@"%s",__func__);
}

- (void)conversation:(AVIMConversation *)conversation membersRemoved:(NSArray *)clientIds byClientId:(NSString *)clientId {
    NSLog(@"%s",__func__);
}

- (void)conversation:(AVIMConversation *)conversation invitedByClientId:(NSString *)clientId {
    NSLog(@"%s",__func__);
}

- (void)conversation:(AVIMConversation *)conversation kickedByClientId:(NSString *)clientId {
    NSLog(@"%s",__func__);
}

/* 如果开启了单点登陆，需要使用代码方法进行监控 */
- (void)client:(AVIMClient *)client didOfflineWithError:(NSError *)error {
    if ([error code] == 4111) {
        //适当的弹出友好提示，告知当前用户的 Client Id 在其他设备上登陆了
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"检测到您已在其他设备登录，请重新登录" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - signature

- (id)conversationSignWithSelfId:(NSString *)clientId conversationId:(NSString *)conversationId targetIds:(NSArray *)targetIds action:(NSString *)action {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:clientId forKey:@"self_id"];
    if (conversationId) {
        [dict setObject:conversationId forKey:@"convid"];
    }
    if (targetIds) {
        [dict setObject:targetIds forKey:@"targetIds"];
    }
    if (action) {
        [dict setObject:action forKey:@"action"];
    }
    //这里是从云代码获取签名，也可以从你的服务器获取
    return [AVCloud callFunction:@"conv_sign" withParameters:dict];
}

- (AVIMSignature *)getAVSignatureWithParams:(NSDictionary *)fields peerIds:(NSArray *)peerIds {
    AVIMSignature *avSignature = [[AVIMSignature alloc] init];
    NSNumber *timestampNum = [fields objectForKey:@"timestamp"];
    long timestamp = [timestampNum longValue];
    NSString *nonce = [fields objectForKey:@"nonce"];
    NSString *signature = [fields objectForKey:@"signature"];
    
    [avSignature setTimestamp:timestamp];
    [avSignature setNonce:nonce];
    [avSignature setSignature:signature];
    return avSignature;
}

- (AVIMSignature *)signatureWithClientId:(NSString *)clientId
                          conversationId:(NSString *)conversationId
                                  action:(NSString *)action
                       actionOnClientIds:(NSArray *)clientIds {
    do {
        if ([action isEqualToString:@"open"] || [action isEqualToString:@"start"]) {
            action = nil;
            break;
        }
        if ([action isEqualToString:@"remove"]) {
            action = @"kick";
            break;
        }
        if ([action isEqualToString:@"add"]) {
            action = @"invite";
            break;
        }
    } while (0);
    NSDictionary *dict = [self conversationSignWithSelfId:clientId conversationId:conversationId targetIds:clientIds action:action];
    if (dict != nil) {
        return [self getAVSignatureWithParams:dict peerIds:clientIds];
    } else {
        return nil;
    }
}

#pragma mark - File Utils

- (NSString *)getFilesPath {
    NSString *appPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filesPath = [appPath stringByAppendingString:@"/files/"];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDir = YES;
    if ([fileMan fileExistsAtPath:filesPath isDirectory:&isDir] == NO) {
        [fileMan createDirectoryAtPath:filesPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [NSException raise:@"error when create dir" format:@"error"];
        }
    }
    return filesPath;
}

- (NSString *)getPathByObjectId:(NSString *)objectId {
    return [[self getFilesPath] stringByAppendingFormat:@"%@", objectId];
}

- (NSString *)videoPathOfMessag:(AVIMVideoMessage *)message {
    // 视频播放会根据文件扩展名来识别格式
    return [[self getFilesPath] stringByAppendingFormat:@"%@.%@", message.messageId, message.format];
}

- (NSString *)tmpPath {
    return [[self getFilesPath] stringByAppendingFormat:@"%@", [[NSUUID UUID] UUIDString]];
}

- (NSString *)uuid {
    NSString *chars = @"abcdefghijklmnopgrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    assert(chars.length == 62);
    int len = (int)chars.length;
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < 24; i++) {
        int p = arc4random_uniform(len);
        NSRange range = NSMakeRange(p, 1);
        [result appendString:[chars substringWithRange:range]];
    }
    return result;
}

+ (NSError *)errorWithText:(NSString *)text {
    return [NSError errorWithDomain:@"LeanChatLib" code:0 userInfo:@{NSLocalizedDescriptionKey:text}];
}

#pragma mark - Conversation cache

- (NSString *)localKeyWithConversationId:(NSString *)conversationId {
    return [NSString stringWithFormat:@"conv_%@", conversationId];
}

- (AVIMConversation *)lookupConversationById:(NSString *)conversationId {
    //FIXME:the convid is not exist in the table when log out
    AVIMConversation *conversation = [self.client conversationForId:conversationId];
    return conversation;
}

- (void)cacheConversationsWithIds:(NSMutableSet *)conversationIds callback:(AVBooleanResultBlock)callback {
    NSMutableSet *uncacheConversationIds = [[NSMutableSet alloc] init];
    for (NSString *conversationId in conversationIds) {
        AVIMConversation  *conversation = [self lookupConversationById:conversationId];
        if (conversation == nil) {
            [uncacheConversationIds addObject:conversationId];
        }
    }
    [self fetchConversationsWithConversationIds:uncacheConversationIds callback: ^(NSArray *objects, NSError *error) {
        if (error) {
            callback(NO, error);
        } else {
            callback(YES, nil);
        }
    }];
}

- (void)selectOrRefreshConversationsWithBlock:(AVIMArrayResultBlock)block {
    static BOOL refreshedFromServer = NO;
    NSArray *conversations = [[ConversationStore store] selectAllConversations];
    if (refreshedFromServer == NO && self.connect) {
        NSMutableSet *conversationIds = [NSMutableSet set];
        for (AVIMConversation *conversation in conversations) {
            [conversationIds addObject:conversation.conversationId];
        }
        [self fetchConversationsWithConversationIds:conversationIds callback:^(NSArray *objects, NSError *error) {
            if (error) {
                block(conversations, nil);
            } else {
                refreshedFromServer = YES;
                [[ConversationStore store] updateConversations:objects];
                block([[ConversationStore store] selectAllConversations], nil);
            }
        }];
    } else {
        block(conversations, nil);
    }
}

- (void)findRecentConversationsWithBlock:(RecentConversationsCallback)block {
    [self selectOrRefreshConversationsWithBlock:^(NSArray *conversations, NSError *error) {
        NSMutableSet *userIds = [NSMutableSet set];
        NSUInteger totalUnreadCount = 0;
        for (AVIMConversation *conversation in conversations) {
            NSArray *lastestMessages = [conversation queryMessagesFromCacheWithLimit:1];
            if (lastestMessages.count > 0) {
                conversation.lastMessage = lastestMessages[0];
            }
            if (conversation.type == ConversationTypeSingle) {
                [userIds addObject:conversation.otherId];
            } else {
                if (conversation.lastMessage) {
                    [userIds addObject:conversation.lastMessage.clientId];
                }
            }
            if (conversation.muted == NO) {
                totalUnreadCount += conversation.unreadCount;
            }
        }
        NSArray *sortedRooms = [conversations sortedArrayUsingComparator:^NSComparisonResult(AVIMConversation *conv1, AVIMConversation *conv2) {
            return (NSComparisonResult)(conv2.lastMessage.sendTimestamp - conv1.lastMessage.sendTimestamp);
        }];
        if ([self.userDelegate respondsToSelector:@selector(cacheUserByIds:block:)]) {
            [self.userDelegate cacheUserByIds:userIds block: ^(BOOL succeeded, NSError *error) {
                if (error) {
                    block(nil,0, error);
                } else {
                    block(sortedRooms, totalUnreadCount, error);
                }
            }];
        } else {
            NSLog(@"self.userDelegate not reponds to cacheUserByIds:block:, may have problem");
            block([NSArray array], 0 , nil);
        }
    }];
}

#pragma mark - mention

- (BOOL)isMentionedByMessage:(AVIMTypedMessage *)message {
    if (![message isKindOfClass:[AVIMTextMessage class]]) {
        return NO;
    } else {
        NSString *text = ((AVIMTextMessage *)message).text;
        id<UserModelDelegate> selfUser = [[ChatManager manager].userDelegate getUserById:self.clientId];
        NSString *pattern = [NSString stringWithFormat:@"@%@ ",selfUser.username];
        if([text rangeOfString:pattern].length > 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

#pragma mark - database

- (void)deleteConversation:(AVIMConversation *)conversation {
    [[ConversationStore store] deleteConversation:conversation];
}


@end
