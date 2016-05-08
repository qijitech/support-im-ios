//
//  MessageHelper.m
//  Pods
//
//  Created by shuu on 16/5/7.
//
//

#import "MessageHelper.h"
#import "ChatManager.h"
#import "EmotionUtils.h"
#import "AVIMEmotionMessage.h"

@interface MessageHelper ()

@property (nonatomic, strong) NSCache *attributedStringCache;


@end


@implementation MessageHelper

+ (MessageHelper *)helper {
    static dispatch_once_t token;
    static MessageHelper *messageHelper;
    dispatch_once(&token, ^{
        messageHelper = [[MessageHelper alloc] init];
    });
    return messageHelper;
}

#pragma mark - message

- (NSString *)getMessageTitle:(AVIMTypedMessage *)msg {
    NSString *title;
    AVIMLocationMessage *locationMsg;
    switch (msg.mediaType) {
        case kAVIMMessageMediaTypeText:
            title = [EmotionUtils emojiStringFromString:msg.text];
            break;
            
        case kAVIMMessageMediaTypeAudio:
            title = @"声音";
            break;
            
        case kAVIMMessageMediaTypeImage:
            title = @"图片";
            break;
            
        case kAVIMMessageMediaTypeLocation:
            locationMsg = (AVIMLocationMessage *)msg;
            title = locationMsg.text;
            break;
        case kAVIMMessageMediaTypeEmotion:
            title = @"表情";
            break;
        case kAVIMMessageMediaTypeVideo:
            title = @"视频";
        default:
            break;
    }
    return title;
}

- (NSAttributedString *)attributedStringWithMessage:(AVIMTypedMessage *)message conversation:(AVIMConversation *)conversation {
    NSString *title = [self getMessageTitle:message];
    if (conversation.type == ConversationTypeGroup) {
        id<UserModelDelegate> user = [[ChatManager manager].userDelegate getUserById:message.clientId];
        title = [NSString stringWithFormat:@"%@: %@", user.username, title];
    }
    if (conversation.muted && conversation.unreadCount > 0) {
        title = [NSString stringWithFormat:@"[%ld条] %@", conversation.unreadCount, title];
    }
    NSString *mentionText = @"[有人@你] ";
    NSString *finalText;
    if (conversation.mentioned) {
        finalText = [NSString stringWithFormat:@"%@%@", mentionText, title];
    } else {
        finalText = title;
    }
    if (finalText == nil) {
        finalText = @"";
    }
    if ([self.attributedStringCache objectForKey:finalText]) {
        return [self.attributedStringCache objectForKey:finalText];
    }
    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor grayColor], (id)NSFontAttributeName:font};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:finalText attributes:attributes];
    
    if (conversation.mentioned) {
        NSRange range = [finalText rangeOfString:mentionText];
        [attributedString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:183/255.0 green:20/255.0 blue:20/255.0 alpha:1], NSFontAttributeName : font} range:range];
    }
    
    [self.attributedStringCache setObject:attributedString forKey:finalText];
    
    return attributedString;
}



@end
