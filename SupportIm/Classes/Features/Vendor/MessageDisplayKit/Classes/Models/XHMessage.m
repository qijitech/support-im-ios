//
//  XHMessage.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessage.h"

@implementation XHMessage

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                   timestamp:(NSDate *)timestamp{
    self = [super init];
    if (self) {
        _text = text;
        _sender = sender;
        _timestamp = timestamp;
        _messageMediaType = XHBubbleMessageMediaTypeText;
    }
    return self;
}

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片
 *  @param thumbnailUrl   目标图片在服务器的缩略图地址
 *  @param originPhotoUrl 目标图片在服务器的原图地址
 *  @param sender         发送者
 *  @param date           发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                    photoPath:(NSString *)photoPath
                 thumbnailUrl:(NSString *)thumbnailUrl
               originPhotoUrl:(NSString *)originPhotoUrl
                       sender:(NSString *)sender
                    timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        _photo = photo;
        _photoPath = photoPath;
        _thumbnailUrl = thumbnailUrl;
        _originPhotoUrl = originPhotoUrl;
        _sender = sender;
        _timestamp = timestamp;
        _messageMediaType = XHBubbleMessageMediaTypePhoto;
    }
    return self;
}

/**
 *  初始化视频类型的消息
 *
 *  @param videoConverPhoto 目标视频的封面图
 *  @param videoPath        目标视频的本地路径，如果是下载过，或者是从本地发送的时候，会存在
 *  @param videoUrl         目标视频在服务器上的地址
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVideoConverPhoto:(UIImage *)videoConverPhoto
                               videoPath:(NSString *)videoPath
                                videoUrl:(NSString *)videoUrl
                                  sender:(NSString *)sender
                               timestamp:(NSDate *)timestamp{
    self = [super init];
    if (self) {
        _videoConverPhoto = videoConverPhoto;
        _videoPath = videoPath;
        _videoUrl = videoUrl;
        _sender = sender;
        _timestamp = timestamp;
        _messageMediaType = XHBubbleMessageMediaTypeVideo;
    }
    return self;
}

/**
 *  初始化语音类型的消息
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                    voiceDuration:(NSString *)voiceDuration
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp{
    
    return [self initWithVoicePath:voicePath voiceUrl:voiceUrl voiceDuration:voiceDuration sender:sender timestamp:timestamp isRead:YES];
}

/**
 *  初始化语音类型的消息。增加已读未读标记
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *  @param isRead           已读未读标记
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                    voiceDuration:(NSString *)voiceDuration
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp
                           isRead:(BOOL)isRead{
    self = [super init];
    if (self) {
        _voicePath = voicePath;
        _voiceUrl = voiceUrl;
        _voiceDuration = voiceDuration;
        
        _sender = sender;
        _timestamp = timestamp;
        _isRead = isRead;
        
        _messageMediaType = XHBubbleMessageMediaTypeVoice;
    }
    return self;
}

- (instancetype)initWithEmotionPath:(NSString *)emotionPath
                             sender:(NSString *)sender
                          timestamp:(NSDate *)timestamp {
    return [self initWithEmotionPath:emotionPath emotionName:nil sender:sender timestamp:timestamp];
}

- (instancetype)initWithEmotionPath:(NSString *)emotionPath
                        emotionName:(NSString *)emotionName
                             sender:(NSString *)sender
                          timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        _emotionPath = emotionPath;
        _emotionName = emotionName;
        _sender = sender;
        _timestamp = timestamp;
        
        _messageMediaType = XHBubbleMessageMediaTypeEmotion;
    }
    return self;
}

- (instancetype)initWithLocalPositionPhoto:(UIImage *)localPositionPhoto
                              geolocations:(NSString *)geolocations
                                  location:(CLLocation *)location
                                    sender:(NSString *)sender
                                 timestamp:(NSDate *)timestamp{
    self = [super init];
    if (self) {
        _localPositionPhoto = localPositionPhoto;
        _geolocations = geolocations;
        _location = location;
        
        _sender = sender;
        _timestamp = timestamp;
        
        _messageMediaType = XHBubbleMessageMediaTypeLocalPosition;
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        
        _text = [aDecoder decodeObjectForKey:@"text"];
        
        _photo = [aDecoder decodeObjectForKey:@"photo"];
        _thumbnailUrl = [aDecoder decodeObjectForKey:@"thumbnailUrl"];
        _originPhotoUrl = [aDecoder decodeObjectForKey:@"originPhotoUrl"];
        
        _videoConverPhoto = [aDecoder decodeObjectForKey:@"videoConverPhoto"];
        _videoPath = [aDecoder decodeObjectForKey:@"videoPath"];
        _videoUrl = [aDecoder decodeObjectForKey:@"videoUrl"];
        
        _voicePath = [aDecoder decodeObjectForKey:@"voicePath"];
        _voiceUrl = [aDecoder decodeObjectForKey:@"voiceUrl"];
        _voiceDuration = [aDecoder decodeObjectForKey:@"voiceDuration"];
        
        _emotionPath = [aDecoder decodeObjectForKey:@"emotionPath"];
        
        _localPositionPhoto = [aDecoder decodeObjectForKey:@"localPositionPhoto"];
        _geolocations = [aDecoder decodeObjectForKey:@"geolocations"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        
        _avator = [aDecoder decodeObjectForKey:@"lcim_conversation_placeholder_avator"];
        _avatorUrl = [aDecoder decodeObjectForKey:@"avatorUrl"];
        
        _sender = [aDecoder decodeObjectForKey:@"sender"];
        _timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        _messageId = [aDecoder decodeObjectForKey:@"messageId"];
        _conversationId = [aDecoder decodeObjectForKey:@"conversationId"];
        _messageMediaType = [aDecoder decodeIntForKey:@"messageMediaType"];
        _status = [aDecoder decodeIntForKey:@"status"];
        _photoPath = [aDecoder decodeObjectForKey:@"photoPath"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"text"];
    
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.thumbnailUrl forKey:@"thumbnailUrl"];
    [aCoder encodeObject:self.originPhotoUrl forKey:@"originPhotoUrl"];
    
    [aCoder encodeObject:self.videoConverPhoto forKey:@"videoConverPhoto"];
    [aCoder encodeObject:self.videoPath forKey:@"videoPath"];
    [aCoder encodeObject:self.videoUrl forKey:@"videoUrl"];
    
    [aCoder encodeObject:self.voicePath forKey:@"voicePath"];
    [aCoder encodeObject:self.voiceUrl forKey:@"voiceUrl"];
    [aCoder encodeObject:self.voiceDuration forKey:@"voiceDuration"];
    
    [aCoder encodeObject:self.emotionPath forKey:@"emotionPath"];
    
    [aCoder encodeObject:self.localPositionPhoto forKey:@"localPositionPhoto"];
    [aCoder encodeObject:self.geolocations forKey:@"geolocations"];
    [aCoder encodeObject:self.location forKey:@"location"];
    
    [aCoder encodeObject:self.sender forKey:@"sender"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeObject:self.messageId forKey:@"messageId"];
    [aCoder encodeObject:self.conversationId forKey:@"conversationId"];
    [aCoder encodeInt:self.messageMediaType forKey:@"messageMediaType"];
    [aCoder encodeInt:self.status forKey:@"status"];
    [aCoder encodeObject:self.photoPath forKey:@"photoPath"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    XHMessage *message;
    switch (self.messageMediaType) {
        case XHBubbleMessageMediaTypeText:
            message = [[[self class] allocWithZone:zone] initWithText:[self.text copy]
                                                               sender:[self.sender copy]
                                                            timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypePhoto:
            message =  [[[self class] allocWithZone:zone] initWithPhoto:[self.photo copy]
                                                              photoPath:[self.photoPath copy]
                                                           thumbnailUrl:[self.thumbnailUrl copy]
                                                         originPhotoUrl:[self.originPhotoUrl copy]
                                                                 sender:[self.sender copy]
                                                              timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeVideo:
            message = [[[self class] allocWithZone:zone] initWithVideoConverPhoto:[self.videoConverPhoto copy]
                                                                        videoPath:[self.videoPath copy]
                                                                         videoUrl:[self.videoUrl copy]
                                                                           sender:[self.sender copy]
                                                                        timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeVoice:
            message =  [[[self class] allocWithZone:zone] initWithVoicePath:[self.voicePath copy]
                                                                   voiceUrl:[self.voiceUrl copy]
                                                              voiceDuration:[self.voiceDuration copy]
                                                                     sender:[self.sender copy]
                                                                  timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeEmotion:
            message =  [[[self class] allocWithZone:zone] initWithEmotionPath:[self.emotionPath copy]
                                                                  emotionName:[self.emotionName copy]
                                                                       sender:[self.sender copy]
                                                                    timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeLocalPosition:
            message =  [[[self class] allocWithZone:zone] initWithLocalPositionPhoto:[self.localPositionPhoto copy]
                                                                        geolocations:[self.geolocations copy]
                                                                            location:[self.location copy]
                                                                              sender:[self.sender copy]
                                                                           timestamp:[self.timestamp copy]];
    }
    message.photo = [self.photo copy];
    message.photoPath = [self.photoPath copy];
    message.messageId = [self.messageId copy];
    message.conversationId = [self.conversationId copy];
    message.messageMediaType = self.messageMediaType;
    message.status = self.status;
    return message;
}

@end
