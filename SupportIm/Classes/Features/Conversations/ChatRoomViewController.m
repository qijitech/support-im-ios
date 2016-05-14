//
//  ChatRoomViewController.m
//  Pods
//
//  Created by shuu on 16/5/8.
//
//

#import <CommonCrypto/CommonCrypto.h>

#import "ChatRoomViewController.h"
#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"
#import "XHAudioPlayerHelper.h"
#import "StatusView.h"
#import "AVIMConversation+Custom.h"
#import "SoundManager.h"
#import "ConversationStore.h"
#import "FailedMessageStore.h"
#import "AVIMEmotionMessage.h"
#import "EmotionUtils.h"
#import "User.h"
#import "LocationViewController.h"
#import "SKToastUtil.h"
#import "ShowSharedLocationViewController.h"

static NSInteger const kOnePageSize = 10;

typedef void (^SendMessageSuccessBlock)(NSString *messageUUID);
typedef void (^ErrorBlock)(NSString *messageUUID, NSError *error);


@interface ChatRoomViewController ()

@property (nonatomic, strong, readwrite) AVIMConversation *conversation;

/*!
 * msgs and messages are not repeated, this means online messages, which means sending succeed.
 * When deal with those messages which are sent failed, you must use self.messages instead of this.
 */

@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (nonatomic, strong) NSArray *emotionManagers;
@property (nonatomic, strong) StatusView *clientStatusView;

@end

@implementation ChatRoomViewController

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // 配置输入框UI的样式
        //self.allowsSendVoice = NO;
//        self.allowsSendFace = NO;
        //self.allowsSendMultiMedia = NO;
        self.loadingMoreMessage = NO;
        _avimTypedMessage = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithConversation:(AVIMConversation *)conversation {
    self = [self init];
    if (self) {
        _conversation = conversation;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initBarButton];
    [self initBottomMenuAndEmotionView];
    [self.view addSubview:self.clientStatusView];
    // 设置自身用户名
    id<UserModelDelegate> selfUser = [[ChatManager manager].userDelegate getUserById:[ChatManager manager].clientId];
    self.messageSender = [selfUser username];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMessageDelivered:) name:kNotificationMessageDelivered object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshConversation) name:kNotificationConversationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusView) name:kNotificationConnectivityUpdated object:nil];
    [self refreshConversation];
    [self loadMessagesWhenInit];
    [self updateStatusView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [ChatManager manager].chattingConversationId = self.conversation.conversationId;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ChatManager manager].chattingConversationId = nil;
    if (self.avimTypedMessage.count > 0) {
        [self updateConversationAsRead];
    }
    [[XHAudioPlayerHelper shareInstance] stopAudio];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationMessageDelivered object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationConversationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationConnectivityUpdated object:nil];
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
}

#pragma mark - ui init

- (void)initBarButton {
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backBtn];
}

- (void)initBottomMenuAndEmotionView {
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location"];
    NSArray *plugTitle = @[@"照片", @"拍摄", @"定位"];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
    
    _emotionManagers = [EmotionUtils emotionManagers];
    self.emotionManagerView.isShowEmotionStoreButton = YES;
    [self.emotionManagerView reloadData];
}

- (void)refreshConversation {
    self.title = self.conversation.displayName;
}

#pragma mark - connect status view

- (StatusView *)clientStatusView {
    if (_clientStatusView == nil) {
        _clientStatusView = [[StatusView alloc] initWithFrame:CGRectMake(0, 64, self.messageTableView.frame.size.width, kStatusViewHight)];
        _clientStatusView.hidden = YES;
    }
    return _clientStatusView;
}

- (void)updateStatusView {
    // If statusview effect experience , note all. heheda
    
    //    if ([ChatManager manager].connect) {
    //        self.tableView.tableHeaderView = nil ;
    //    }else {
    //        self.tableView.tableHeaderView = self.clientStatusView;
    //    }
}

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell {
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            XHDisplayMediaViewController *messageDisplayTextView = [[XHDisplayMediaViewController alloc] init];
            messageDisplayTextView.message = message;
            disPlayViewController = messageDisplayTextView;
            break;
        }
            
        case XHBubbleMessageMediaTypeVoice: {
            //TODO:
            // Mark the voice as read and hide the red dot.
            //message.isRead = YES;
            //messageTableViewCell.messageBubbleView.voiceUnreadDotImageView.hidden = YES;
            [[XHAudioPlayerHelper shareInstance] setDelegate:self];
            if (_currentSelectedCell) {
                [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
            }
            if (_currentSelectedCell == messageTableViewCell) {
                [messageTableViewCell.messageBubbleView.animationVoiceImageView stopAnimating];
                [[XHAudioPlayerHelper shareInstance] stopAudio];
                self.currentSelectedCell = nil;
            } else {
                self.currentSelectedCell = messageTableViewCell;
                [messageTableViewCell.messageBubbleView.animationVoiceImageView startAnimating];
                [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:message.voicePath toPlay:YES];
            }
            break;
        }
            
        case XHBubbleMessageMediaTypeEmotion:
            DLog(@"facePath : %@", message.emotionPath);
            break;
            
        case XHBubbleMessageMediaTypeLocalPosition: {
            DLog(@"facePath : %@", message.localPositionPhoto);
//            XHDisplayLocationViewController *displayLocationViewController = [[XHDisplayLocationViewController alloc] init];
//            displayLocationViewController.message = message;
//            disPlayViewController = displayLocationViewController;
            [self openSharedLoactionWithMessage:message];
            
            break;
        }
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:NO];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"text : %@", message.text);
    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:NO];
}

- (void)didSelectedAvatorOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    DLog(@"indexPath : %@", indexPath);
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType {
}

- (void)didRetrySendMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath {
    [self resendMessageAtIndexPath:indexPath discardIfFailed:false];
}

#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHMessageTableViewController Delegate

- (void)loadMoreMessagesScrollTotop {
    [self loadOldMessages];
}

#pragma mark - didSend delegate

//发送文本消息的回调方法
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([ChatManager manager].client.status != AVIMClientStatusOpened) {
        return;
    }
    if ([text length] > 0 ) {
//        XHMessage *xhMessage = [[XHMessage alloc] initWithText:[EmotionUtils emojiStringFromString:text] sender:sender timestamp:date];
        XHMessage *xhMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date];
        [self sendMessage:xhMessage];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    }
}

//发送图片消息的回调方法
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([ChatManager manager].client.status != AVIMClientStatusOpened) {
        return;
    }
    [self sendImage:photo fromSender:sender];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}

// 发送视频消息的回调方法
- (void)didSendVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([ChatManager manager].client.status != AVIMClientStatusOpened) {
        return;
    }
    AVIMVideoMessage *sendVideoMessage = [AVIMVideoMessage messageWithText:nil attachedFilePath:videoPath attributes:nil];
    [self sendMessage:sendVideoMessage];
}

// 发送语音消息的回调方法
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([ChatManager manager].client.status != AVIMClientStatusOpened) {
        return;
    }
    [self sendVoiceWithPath:voicePath fromSender:sender];
}

// 发送表情消息的回调方法
- (void)didSendEmotion:(NSString *)emotion fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([ChatManager manager].client.status != AVIMClientStatusOpened) {
        return;
    }
    if ([emotion length] > 0 ) {
        //        XHMessage *xhMessage = [[XHMessage alloc] initWithText:[EmotionUtils emojiStringFromString:text] sender:sender timestamp:date];
        XHMessage *xhMessage = [[XHMessage alloc] initWithText:emotion sender:sender timestamp:date];
        [self sendMessage:xhMessage];
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    }
//    if ([emotion hasPrefix:@":"]) {
//        // 普通表情
//        UITextView *textView = self.messageInputView.inputTextView;
//        NSRange range = [textView selectedRange];
//        NSMutableString *str = [[NSMutableString alloc] initWithString:textView.text];
//        [str deleteCharactersInRange:range];
//        [str insertString:emotion atIndex:range.location];
//        textView.text = [EmotionUtils emojiStringFromString:str];
//        textView.selectedRange = NSMakeRange(range.location + emotion.length, 0);
//        //TODO:
//        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
//    } else {
//        NSString *path = [[NSBundle mainBundle] pathForResource:emotion ofType:@"gif"];
//        XHMessage *message = [[XHMessage alloc] initWithEmotionPath:path emotionName:emotion sender:sender timestamp:nil];
//        [self sendMessage:message];
//        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
//    }
}

- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    if ([ChatManager manager].client.status != AVIMClientStatusOpened) {
        return;
    }
    //TODO:
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
}

#pragma mark -  UI config Delegate Method

// 是否显示时间轴Label的回调方法
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //FIXME:这里只能设NO, 不然会引起显示异常
        return NO;
    }  else {
        
        // sometimes maybe crash ,because indexPath.row
        NSInteger index = indexPath.row >= self.messages.count ? self.messages.count - 1 : indexPath.row;
        XHMessage *msg = [self.messages objectAtIndex:index];
        
//        XHMessage *msg = [self.messages objectAtIndex:indexPath.row];
        XHMessage *lastMsg = [self.messages objectAtIndex:indexPath.row - 1];
        int interval = [msg.timestamp timeIntervalSinceDate:lastMsg.timestamp];
        if (interval > 60 * 3) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (BOOL)shouldDisplayPeerName {
    return YES;
}

// 配置Cell的样式或者字体
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    XHMessage *msg = [self.messages objectAtIndex:indexPath.row];
    if ([self shouldDisplayTimestampForRowAtIndexPath:indexPath]) {
        NSDate *ts = msg.timestamp;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd HH:mm"];
        NSString *str = [dateFormatter stringFromDate:ts];
        cell.timestampLabel.text = str;
    }
    SETextView *textView = cell.messageBubbleView.displayTextView;
    if (msg.bubbleMessageType == XHBubbleMessageTypeSending) {
        [textView setTextColor:[UIColor whiteColor]];
    } else {
        [textView setTextColor:[UIColor blackColor]];
    }
}

// 协议回掉是否支持用户手动滚动
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

# pragma mark - LocationShare

- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    if (index == 2) {
        NSLog(@"%s",__func__);
        
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                  message:nil
                                                                           preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction: [UIAlertAction actionWithTitle: @"发送位置"
                                                             style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               LocationViewController *locationViewController = [[LocationViewController alloc] init];
                                                               locationViewController.locationShareBlock = ^(NSString *location, CLLocationCoordinate2D coordinate, UIImage *image){
                                                                   [self sendLocationWithLocation:location coordinate:coordinate image:image];
                                                               };
                                                               [self.navigationController pushViewController:locationViewController animated:YES];
                                                           }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"共享实时位置"
                                                             style: UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               [SKToastUtil toastWithText:@"not implement yet"];
                                                           }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"取消"
                                                             style: UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction *action) {
                                                           }]];
        [self presentViewController:alertController animated:YES completion:nil];

        return;
    }
    [super didSelecteShareMenuItem:shareMenuItem atIndex:index];
}

- (void)sendLocationWithLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coordinate image:(UIImage *)image {
    
    CLLocation *cllocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    XHMessage *message = [[XHMessage alloc] initWithLocalPositionPhoto:image geolocations:location location:cllocation sender:nil timestamp:nil];
    message.text = location;
    [self sendMessage:message];

}

- (void)openSharedLoactionWithMessage:(id<XHMessageModel>)message {
    ShowSharedLocationViewController *locationViewController = [[ShowSharedLocationViewController alloc] initWithMessage:message];
    [self.navigationController pushViewController:locationViewController animated:YES];
}

#pragma mark - @ reference other

- (void)didInputAtSignOnMessageTextView:(XHMessageTextView *)messageInputTextView {
    
}

#pragma mark - alert and async utils

- (void)alert:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil message:msg delegate:nil
                              cancelButtonTitle   :@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)alertError:(NSError *)error {
    if (error) {
        if (error.code == kAVIMErrorConnectionLost) {
            [self alert:@"未能连接聊天服务"];
        } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
            [self alert:@"网络连接发生错误"];
        } else {
            [self alert:[NSString stringWithFormat:@"%@", error]];
        }
        return YES;
    }
    return NO;
}

- (BOOL)filterError:(NSError *)error {
    return [self alertError:error] == NO;
}


- (void)runInMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}

- (void)runInGlobalQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}

#pragma mark - LeanCloud

#pragma mark - conversations store

- (void)updateConversationAsRead {
    [[ConversationStore store] insertConversation:self.conversation];
    [[ConversationStore store] updateUnreadCountToZeroWithConversation:self.conversation];
    [[ConversationStore store] updateMentioned:NO conversation:self.conversation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUnreadsUpdated object:nil];
}

#pragma mark - send message

- (void)sendImage:(UIImage *)image fromSender:(NSString *)sender {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    NSString *path = [[ChatManager manager] tmpPath];
    NSError *error;
    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    if (error == nil) {
        XHMessage *message = [[XHMessage alloc]
                              initWithPhoto:image
                              photoPath:path
                              thumbnailUrl:nil
                              originPhotoUrl:nil
                              sender:sender
                              timestamp:nil
                              ];
        [self sendMessage:message];
    } else {
        [self alert:@"write image to file error"];
    }
}

- (void)sendVoiceWithPath:(NSString *)voicePath fromSender:(NSString *)sender {
    XHMessage *message = [[XHMessage alloc] initWithVoicePath:voicePath
                                                     voiceUrl:nil
                                                voiceDuration:nil
                                                       sender:sender
                                                    timestamp:nil
                          ];
    [self sendMessage:message];
}

- (void)sendLocationWithLatitude:(double)latitude longitude:(double)longitude address:(NSString *)address {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    XHMessage *message = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:nil location:location sender:nil timestamp:nil];
    [self sendMessage:message];
}

- (AVIMTypedMessage *)getAVIMTypedMessageWithMessage:(XHMessage *)message {
    AVIMTypedMessage *avimTypedMessage;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeText: {
//            avimTypedMessage = [AVIMTextMessage messageWithText:[EmotionUtils plainStringFromEmojiString:message.text] attributes:nil];
            avimTypedMessage = [AVIMTextMessage messageWithText:message.text attributes:nil];
            break;
        }
        case XHBubbleMessageMediaTypeVideo:
        case XHBubbleMessageMediaTypePhoto: {
            avimTypedMessage = [AVIMImageMessage messageWithText:nil attachedFilePath:message.photoPath attributes:nil];
            break;
        }
        case XHBubbleMessageMediaTypeVoice: {
            avimTypedMessage = [AVIMAudioMessage messageWithText:nil attachedFilePath:message.voicePath attributes:nil];
            break;
        }
            
        case XHBubbleMessageMediaTypeEmotion:
//            avimTypedMessage = [AVIMEmotionMessage messageWithEmotionPath:message.emotionName];
            avimTypedMessage = [AVIMTextMessage messageWithText:message.text attributes:nil];
            break;
            
        case XHBubbleMessageMediaTypeLocalPosition: {
            // used chat framework not support location share ... if need this function ... you know ... he he da
            //had implement. i'm so dia
            avimTypedMessage = [AVIMLocationMessage messageWithText:@"[位置]" latitude:message.location.coordinate.latitude longitude:message.location.coordinate.longitude attributes:nil];
//            avimTypedMessage = [AVIMLocationMessage messageWithText:message.text latitude:message.location.coordinate.latitude longitude:message.location.coordinate.longitude attributes:@{@"localPositionPhoto":message.localPositionPhoto}];
            break;
        }
    }
    avimTypedMessage.sendTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return avimTypedMessage;
}

- (void)sendMessage:(XHMessage *)message {
    [self sendMessage:message success:^(NSString *messageUUID) {
        [[SoundManager manager] playSendSoundIfNeed];
    } failed:^(NSString *messageUUID, NSError *error) {
        message.messageId = messageUUID;
        [[FailedMessageStore store] insertFailedXHMessage:message];
    }];
}

- (void)sendMessage:(XHMessage *)message success:(SendMessageSuccessBlock)success failed:(ErrorBlock)failed {
    message.conversationId = self.conversation.conversationId;
    message.status = XHMessageStatusSending;
    AVIMTypedMessage *avimTypedMessage = [self getAVIMTypedMessageWithMessage:message];
    [self.avimTypedMessage addObject:avimTypedMessage];
    [self preloadMessageToTableView:message];
    
    // if `message.messageId` is not nil, it is a failed message being resended.
    NSString *messageUUID = (message.messageId) ? message.messageId : [[NSUUID UUID] UUIDString];
    NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@, %@", @(__PRETTY_FUNCTION__), @(__LINE__), messageUUID, @(message.messageId.integerValue));
    [[ChatManager manager] sendMessage:avimTypedMessage conversation:self.conversation callback:^(BOOL succeeded, NSError *error) {
        if (error) {
            message.status = XHMessageStatusFailed;
            !failed ?: failed(messageUUID, error);
        } else {
            message.status = XHMessageStatusSent;
            !success ?: success(messageUUID);
        }
        //TODO:
        //???:should I cache message even failed
        [self cacheMessages:@[avimTypedMessage] callback:nil];
        dispatch_async(dispatch_get_main_queue(),^{
            NSUInteger index = [self.messages indexOfObject:message];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }];
}

- (void)resendMessageAtIndexPath:(NSIndexPath *)indexPath discardIfFailed:(BOOL)discardIfFailed {
    //FIXME:why also get the last message when i want to get current xhMessage?
    
    // If use simulator resend failed message sometimes will fail because bundle maybe change. So,if you find problem with it...he he da
    
    NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@ %@", @(__PRETTY_FUNCTION__), @(__LINE__), @(indexPath.row), @(self.messages.count));
    XHMessage *xhMessage =  self.messages[indexPath.row];
    [self.messages removeObjectAtIndex:indexPath.row];
    [self.avimTypedMessage removeObjectAtIndex:indexPath.row];
    [self.messageTableView reloadData];
    [self sendMessage:xhMessage success:^(NSString *messageUUID) {
        [[FailedMessageStore store] deleteFailedMessageByRecordId:messageUUID];
    } failed:^(NSString *messageUUID, NSError *error) {
        if (discardIfFailed) {
            // 服务器连通的情况下重发依然失败，说明消息有问题，如音频文件不存在，删掉这条消息 ? maybe wrong ?
            [[FailedMessageStore store] deleteFailedMessageByRecordId:messageUUID];
        }
    }];
}

#pragma mark - receive and delivered

- (void)receiveMessage:(NSNotification *)notification {
    AVIMTypedMessage *message = notification.object;
    if ([message.conversationId isEqualToString:self.conversation.conversationId]) {
        if (self.conversation.muted == NO) {
            [[SoundManager manager] playReceiveSoundIfNeed];
        }
        [self insertMessage:message];
        //        [[CDChatManager manager] setZeroUnreadWithConversationId:self.conversation.conversationId];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:kCDNotificationMessageReceived object:nil];
    }
}

- (void)onMessageDelivered:(NSNotification *)notification {
    AVIMTypedMessage *message = notification.object;
    if ([message.conversationId isEqualToString:self.conversation.conversationId]) {
        AVIMTypedMessage *foundMessage;
        NSInteger pos;
        for (pos = 0; pos < self.avimTypedMessage.count; pos++) {
            AVIMTypedMessage *msg = self.avimTypedMessage[pos];
            if ([msg.messageId isEqualToString:message.messageId]) {
                foundMessage = msg;
                break;
            }
        }
        if (foundMessage !=nil) {
            XHMessage *xhMsg = [self getXHMessageByMsg:foundMessage];
            [self.messages setObject:xhMsg atIndexedSubscript:pos];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pos inSection:0];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollToBottomAnimated:YES];
        }
    }
}

#pragma mark - modal convert

- (NSDate *)getTimestampDate:(int64_t)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
}

- (XHMessage *)getXHMessageByMsg:(AVIMTypedMessage *)message {
    id<UserModelDelegate> fromUser = [[ChatManager manager].userDelegate getUserById:message.clientId];
    XHMessage *xhMessage;
    NSDate *time = [self getTimestampDate:message.sendTimestamp];
    if (message.mediaType == kAVIMMessageMediaTypeText) {
        AVIMTextMessage *textMsg = (AVIMTextMessage *)message;
        xhMessage = [[XHMessage alloc] initWithText:[EmotionUtils emojiStringFromString:textMsg.text] sender:fromUser.displayName timestamp:time];
    } else if (message.mediaType == kAVIMMessageMediaTypeAudio) {
        AVIMAudioMessage *audioMsg = (AVIMAudioMessage *)message;
        NSString *duration = [NSString stringWithFormat:@"%.0f", audioMsg.duration];
        xhMessage = [[XHMessage alloc] initWithVoicePath:audioMsg.file.localPath voiceUrl:nil voiceDuration:duration sender:fromUser.displayName timestamp:time];
    } else if (message.mediaType == kAVIMMessageMediaTypeLocation) {
        AVIMLocationMessage *locationMsg = (AVIMLocationMessage *)message;
        xhMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:locationMsg.text location:[[CLLocation alloc] initWithLatitude:locationMsg.latitude longitude:locationMsg.longitude] sender:fromUser.displayName timestamp:time];
    } else if (message.mediaType == kAVIMMessageMediaTypeImage) {
        AVIMImageMessage *imageMsg = (AVIMImageMessage *)message;
        UIImage *image;
        NSError *error;
        NSData *data = [imageMsg.file getData:&error];
        if (error) {
            DLog(@"get Data error: %@", error);
        } else {
            image = [UIImage imageWithData:data];
        }
        //TODO: image and photoPath may all be nil
        xhMessage = [[XHMessage alloc] initWithPhoto:image photoPath:nil thumbnailUrl:nil originPhotoUrl:nil sender:fromUser.displayName timestamp:time];
    } else if (message.mediaType == kAVIMMessageMediaTypeEmotion) {
        AVIMEmotionMessage *emotionMsg = (AVIMEmotionMessage *)message;
        NSString *path = [[NSBundle mainBundle] pathForResource:emotionMsg.emotionPath ofType:@"gif"];
        xhMessage = [[XHMessage alloc] initWithEmotionPath:path sender:fromUser.displayName timestamp:time];
    } else if (message.mediaType == kAVIMMessageMediaTypeVideo) {
        AVIMVideoMessage *videoMsg = (AVIMVideoMessage *)message;
        NSString *path = [[ChatManager manager] videoPathOfMessag:videoMsg];
        xhMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:path] videoPath:path videoUrl:nil sender:fromUser.displayName timestamp:time];
    } else {
        xhMessage = [[XHMessage alloc] initWithText:@"未知消息" sender:fromUser.displayName timestamp:time];
        DLog("unkonwMessage");
    }
    
    xhMessage.avator = nil;
    xhMessage.avatorUrl = [fromUser avatarUrl];
    
    if ([[ChatManager manager].clientId isEqualToString:message.clientId]) {
        xhMessage.bubbleMessageType = XHBubbleMessageTypeSending;
    } else {
        xhMessage.bubbleMessageType = XHBubbleMessageTypeReceiving;
    }
    NSInteger msgStatuses[4] = { AVIMMessageStatusSending, AVIMMessageStatusSent, AVIMMessageStatusDelivered, AVIMMessageStatusFailed };
    NSInteger xhMessageStatuses[4] = { XHMessageStatusSending, XHMessageStatusSent, XHMessageStatusReceived, XHMessageStatusFailed };
    
    if (xhMessage.bubbleMessageType == XHBubbleMessageTypeSending) {
        XHMessageStatus status = XHMessageStatusReceived;
        int i;
        for (i = 0; i < 4; i++) {
            if (msgStatuses[i] == message.status) {
                status = xhMessageStatuses[i];
                break;
            }
        }
        xhMessage.status = status;
    } else {
        xhMessage.status = XHMessageStatusReceived;
    }
    return xhMessage;
}

- (NSMutableArray *)getXHMessages:(NSArray *)avimTypedMessage {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (AVIMTypedMessage *msg in avimTypedMessage) {
        XHMessage *xhMsg = [self getXHMessageByMsg:msg];
        if (xhMsg) {
            [messages addObject:xhMsg];
        }
    }
    return messages;
}

- (NSMutableArray *)getAVIMMessages:(NSArray<XHMessage *> *)xhMessages {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (XHMessage *message in xhMessages) {
        AVIMTypedMessage *avimTypedMessage = [self getAVIMTypedMessageWithMessage:message];
        if (avimTypedMessage) {
            [messages addObject:avimTypedMessage];
        }
    }
    return messages;
}

#pragma mark - query messages

- (void)queryAndCacheMessagesWithTimestamp:(int64_t)timestamp block:(AVIMArrayResultBlock)block {
    [[ChatManager manager] queryTypedMessagesWithConversation:self.conversation timestamp:timestamp limit:kOnePageSize block:^(NSArray *avimTypedMessage, NSError *error) {
        if (error) {
            block(avimTypedMessage, error);
        } else {
            [self cacheMessages:avimTypedMessage callback:^(BOOL succeeded, NSError *error) {
                block (avimTypedMessage, error);
            }];
        }
    }];
}

- (void)loadMessagesWhenInit {
    if (self.loadingMoreMessage) {
        return;
    } else {
        self.loadingMoreMessage = YES;
        [self queryAndCacheMessagesWithTimestamp:0 block:^(NSArray *avimTypedMessage, NSError *error) {
            if ([self filterError:error]) {
                // 失败消息加到末尾，因为 SDK 缓存不保存它们
                //TODO:why only when the net is ok, can the failed messages load?!!
                NSMutableArray *xhSucceedMessags = [self getXHMessages:avimTypedMessage];
                self.messages = [NSMutableArray arrayWithArray:xhSucceedMessags];
                NSArray<XHMessage *> *failedMessages = [[FailedMessageStore store] selectFailedMessagesByConversationId:self.conversation.conversationId];
                NSMutableArray *allFailedAVIMMessages = [self getAVIMMessages:failedMessages];
                NSMutableArray *allMessages = [NSMutableArray arrayWithArray:avimTypedMessage];
                [allMessages addObjectsFromArray:[allFailedAVIMMessages copy]];
                [self.messages addObjectsFromArray:failedMessages];
                self.avimTypedMessage = allMessages;
                [self.messageTableView reloadData];
                [self scrollToBottomAnimated:NO];
                
                if (self.avimTypedMessage.count > 0) {
                    [self updateConversationAsRead];
                }
                
                // 如果连接上，则重发所有的失败消息。若夹杂在历史消息中间不好处理
                if ([ChatManager manager].connect) {
                    for (NSInteger row = self.messages.count; row < allMessages.count; row ++) {
                        [self resendMessageAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] discardIfFailed:YES];
                    }
                }
            }
            self.loadingMoreMessage = NO;
        }];
    }
}

- (void)loadOldMessages {
    if (self.messages.count == 0 || self.loadingMoreMessage) {
        return;
    }
    self.loadingMoreMessage = YES;
    AVIMTypedMessage *msg = [self.avimTypedMessage objectAtIndex:0];
    int64_t timestamp = msg.sendTimestamp;
    [self queryAndCacheMessagesWithTimestamp:timestamp block:^(NSArray *avimTypedMessage, NSError *error) {
        self.shouldLoadMoreMessagesScrollToTop = YES;
        if ([self filterError:error]) {
            if (avimTypedMessage.count == 0) {
                self.shouldLoadMoreMessagesScrollToTop = NO;
                self.loadingMoreMessage = NO;
                return;
            }
            NSMutableArray *xhMsgs = [[self getXHMessages:avimTypedMessage] mutableCopy];
            NSMutableArray *newMsgs = [NSMutableArray arrayWithArray:avimTypedMessage];
            [newMsgs addObjectsFromArray:self.avimTypedMessage];
            self.avimTypedMessage = newMsgs;
            [self insertOldMessages:xhMsgs completion: ^{
                self.loadingMoreMessage = NO;
            }];
        } else {
            self.loadingMoreMessage = NO;
        }
    }];
}

- (void)cacheMessages:(NSArray<AVIMTypedMessage *> *)messages callback:(AVBooleanResultBlock)callback {
    [self runInGlobalQueue:^{
        NSMutableSet *userIds = [[NSMutableSet alloc] init];
        for (AVIMTypedMessage *message in messages) {
            [userIds addObject:message.clientId];
            if (message.mediaType == kAVIMMessageMediaTypeImage || message.mediaType == kAVIMMessageMediaTypeAudio) {
                AVFile *file = message.file;
                if (file && file.isDataAvailable == NO) {
                    NSError *error;
                    // 下载到本地
                    NSData *data = [file getData:&error];
                    if (error || data == nil) {
                        DLog(@"download file error : %@", error);
                    }
                }
            } else if (message.mediaType == kAVIMMessageMediaTypeVideo) {
                NSString *path = [[ChatManager manager] videoPathOfMessag:(AVIMVideoMessage *)message];
                if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    NSError *error;
                    NSData *data = [message.file getData:&error];
                    if (error) {
                        DLog(@"download file error : %@", error);
                    } else {
                        [data writeToFile:path atomically:YES];
                    }
                }
            }
        }
        if ([[ChatManager manager].userDelegate respondsToSelector:@selector(cacheUserByIds:block:)]) {
            [[ChatManager manager].userDelegate cacheUserByIds:userIds block:^(BOOL succeeded, NSError *error) {
                [self runInMainQueue:^{
                    !callback ?: callback(succeeded, error);
                }];
            }];
        } else {
            [self runInMainQueue:^{
                callback(YES, nil);
            }];
        }
    }];
}

- (void)preloadMessageToTableView:(XHMessage *)message {
    [self.messages addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self scrollToBottomAnimated:YES];
}

- (void)insertMessage:(AVIMTypedMessage *)message {
    if (self.loadingMoreMessage) {
        return;
    }
    self.loadingMoreMessage = YES;
    [self cacheMessages:@[message] callback:^(BOOL succeeded, NSError *error) {
        if ([self filterError:error]) {
            XHMessage *xhMessage = [self getXHMessageByMsg:message];
            [self.avimTypedMessage addObject:message];
            [self.messages addObject:xhMessage];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.avimTypedMessage.count -1 inSection:0];
            [self.messageTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self scrollToBottomAnimated:YES];
        }
        self.loadingMoreMessage = NO;
    }];
}



@end
