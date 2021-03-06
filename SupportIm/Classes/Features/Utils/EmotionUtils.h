//
//  EmotionUtils.h
//  Pods
//
//  Created by shuu on 16/5/8.
//
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface EmotionUtils : NSObject

/**
 *  获取 XHEmotionManager Array
 */
+ (NSArray *)emotionManagers;


/**
 *  :smile: 文本转换成原生表情
 */
+ (NSString *)emojiStringFromString:(NSString *)text;

/**
 *  原生表情转换成 :smile: 文本
 */
+ (NSString *)plainStringFromEmojiString:(NSString *)emojiText;

/*!
 *  方便开发者把本地表情保存到云端，调用一次保存到后台
 */
+ (void)saveEmotions;

+ (void)findEmotionWithName:(NSString *)name block:(AVFileResultBlock)block;


@end
