//
//  CDConvDetailMembersSubCell.m
//  LeanChat
//
//  Created by lzw on 15/4/21.
//  Copyright (c) 2015年 AVOS. All rights reserved.
//

#import "LZMembersSubCell.h"

@interface LZMembersSubCell ()

@end

@implementation LZMembersSubCell

+ (CGFloat)heightForCell {
    return kLZMembersSubCellAvatarSize + kLZMembersSubCellSeparator + kLZMembersSubCellLabelHeight;
}

+ (CGFloat)widthForCell {
    return kLZMembersSubCellAvatarSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.usernameLabel];
    }
    return self;
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kLZMembersSubCellAvatarSize, kLZMembersSubCellAvatarSize)];
    }
    return _avatarImageView;
}

- (UILabel *)usernameLabel {
    if (_usernameLabel == nil) {
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_avatarImageView.frame) + kLZMembersSubCellSeparator, CGRectGetWidth(_avatarImageView.frame), kLZMembersSubCellLabelHeight)];
        _usernameLabel.textAlignment = NSTextAlignmentCenter;
        _usernameLabel.font = [UIFont systemFontOfSize:12];
    }
    return _usernameLabel;
}

@end
