//
//  CDConvDetailMembersHeaderView.h
//  LeanChat
//
//  Created by lzw on 15/4/20.
//  Copyright (c) 2015年 AVOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LZMember.h"
#import "LZMembersSubCell.h"

static CGFloat kLZMembersCellLineSpacing = 10;
static CGFloat kLZMembersCellInterItemSpacing = 20;

@protocol LZMembersCellDelegate <NSObject>

- (void)didSelectMember:(LZMember *)member;

- (void)didLongPressMember:(LZMember *)member;

- (void)displayAvatarOfMember:(LZMember *)member atImageView:(UIImageView *)imageView;

@end

@interface LZMembersCell : UITableViewCell

@property (nonatomic, strong) NSArray *members;

@property (nonatomic, strong) id <LZMembersCellDelegate> membersCellDelegate;

+ (CGFloat)heightForMemberCount:(NSInteger )count;

+ (LZMembersCell *)dequeueOrCreateCellByTableView:(UITableView *)tableView;

@end
