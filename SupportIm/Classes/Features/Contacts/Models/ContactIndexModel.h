//
//  ContactIndexModel.h
//  Pods
//
//  Created by shuu on 16/5/14.
//
//

#import <Foundation/Foundation.h>

@interface ContactIndexModel : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *indexSpelling;
@property (nonatomic, strong) NSString *fullSpelling;

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger section;


@end
