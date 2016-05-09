//
//  AVIMCustomMessage.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

//#import "AVIMTypedMessage.h"
#import "SupportIm.h"

/**
 *  自定义消息的类型，需要 > 0
 */
static NSInteger const kAVIMMessageMediaTypeCustom = 3;

/**
 *  自定义 AVIMTypedMessage，自定义的字段都放到 attributes 中来，不要有和 attributes 平级的字段。
 */

@interface AVIMCustomMessage : AVIMTypedMessage <AVIMTypedMessageSubclassing>

+ (instancetype)messageWithAttributes:(NSDictionary *)attributes;


@end
