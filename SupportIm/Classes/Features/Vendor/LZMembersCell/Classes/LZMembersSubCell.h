//
//  CDConvDetailMembersSubCell.h
//  LeanChat
//
//  Created by lzw on 15/4/21.
//  Copyright (c) 2015年 AVOS. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat kLZMembersSubCellAvatarSize = 60;
static CGFloat kLZMembersSubCellLabelHeight = 20;
static CGFloat kLZMembersSubCellSeparator = 5;

@interface LZMembersSubCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *usernameLabel;

+ (CGFloat)heightForCell;

+ (CGFloat)widthForCell;

@end
