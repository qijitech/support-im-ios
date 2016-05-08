//
//  CountryTableViewCell.m
//  SupportIm
//
//  Created by shuu on 16/4/25.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "CountryTableViewCell.h"

@implementation CountryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

+ (NSString *)cellIdentifier {
    static NSString *const kCellIdentifier = @"CountryTableViewCell";
    return kCellIdentifier;
}

@end
