//
//  AVIMEmotionMessage.h
//  Pods
//
//  Created by shuu on 16/5/8.
//
//

#import "AVIMTypedMessage.h"

static AVIMMessageMediaType const kAVIMMessageMediaTypeEmotion = 1;

@interface AVIMEmotionMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>

+ (instancetype)messageWithEmotionPath:(NSString *)emotionPath;

- (NSString *)emotionPath;

@end
