//
//  AVIMEmotionMessage.m
//  Pods
//
//  Created by shuu on 16/5/8.
//
//

#import "AVIMEmotionMessage.h"

static NSString *kAVIMEmotionPath = @"emotionPath";


@implementation AVIMEmotionMessage

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return kAVIMMessageMediaTypeEmotion;
}

+ (instancetype)messageWithEmotionPath:(NSString *)emotionPath {
    return [super messageWithText:nil file:nil attributes:@{kAVIMEmotionPath: emotionPath}];
}

- (NSString *)emotionPath {
    return [self.attributes objectForKey:kAVIMEmotionPath];
}

@end
