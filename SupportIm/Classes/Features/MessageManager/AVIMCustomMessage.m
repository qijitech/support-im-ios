//
//  AVIMCustomMessage.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "AVIMCustomMessage.h"

@implementation AVIMCustomMessage


+ (void)load {
    [self registerSubclass];
}

- (instancetype)init {
    if ((self = [super init])) {
        self.mediaType = [[self class] classMediaType];
    }
    return self;
}

+ (AVIMMessageMediaType)classMediaType {
    return kAVIMMessageMediaTypeCustom;
}

+ (instancetype)messageWithAttributes:(NSDictionary *)attributes {
    AVIMCustomMessage *message = [[self alloc] init];
    message.attributes = attributes;
    return message;
}

@end
