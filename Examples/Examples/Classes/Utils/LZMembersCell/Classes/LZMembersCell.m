//
//  CDConvDetailMembersHeaderView.m
//  LeanChat
//
//  Created by lzw on 15/4/20.
//  Copyright (c) 2015年 AVOS. All rights reserved.
//

#import "LZMembersCell.h"

static NSString *kMCClassMembersHeaderViewCellIndentifer = @"memberCell";

@interface LZMembersCell () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *membersCollectionView;

@end

@implementation LZMembersCell

+ (LZMembersCell *)dequeueOrCreateCellByTableView:(UITableView *)tableView {
    LZMembersCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class] reuseIdentifier]];
    if (cell == nil) {
        cell = [[LZMembersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] reuseIdentifier]];
    }
    return cell;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([LZMembersCell class]);
}

+ (CGFloat)heightForMemberCount:(NSInteger )count {
    if (count == 0) {
        return 0;
    }
    NSInteger column = (CGRectGetWidth([UIScreen mainScreen].bounds) - kLZMembersCellInterItemSpacing) / ([LZMembersSubCell widthForCell] + kLZMembersCellInterItemSpacing);
    NSInteger rows = count / column + (count % column ? 1 : 0);
    return rows *[LZMembersSubCell heightForCell] + (rows + 1) * kLZMembersCellLineSpacing;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.membersCollectionView];
    }
    return self;
}

- (UICollectionView *)membersCollectionView {
    if (_membersCollectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kLZMembersCellLineSpacing;
        layout.minimumInteritemSpacing = kLZMembersCellInterItemSpacing;
        layout.itemSize = CGSizeMake([LZMembersSubCell widthForCell], [LZMembersSubCell heightForCell]);
        _membersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_membersCollectionView registerClass:[LZMembersSubCell class] forCellWithReuseIdentifier:kMCClassMembersHeaderViewCellIndentifer];
        _membersCollectionView.backgroundColor = [UIColor whiteColor];
        _membersCollectionView.showsVerticalScrollIndicator = YES;
        _membersCollectionView.delegate = self;
        _membersCollectionView.dataSource = self;
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressUser:)];
        gestureRecognizer.delegate = self;
        [_membersCollectionView addGestureRecognizer:gestureRecognizer];
    }
    return _membersCollectionView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.membersCollectionView.frame = CGRectMake(kLZMembersCellInterItemSpacing, kLZMembersCellLineSpacing, CGRectGetWidth(self.frame) - 2 * kLZMembersCellInterItemSpacing, CGRectGetHeight(self.frame) - 2 * kLZMembersCellLineSpacing);
}

- (void)setMembers:(NSArray *)members {
    _members = members;
    [self.membersCollectionView reloadData];
    [self setNeedsLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.members.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LZMembersSubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMCClassMembersHeaderViewCellIndentifer forIndexPath:indexPath];
    LZMember *user = [self.members objectAtIndex:indexPath.row];
    if ([self.membersCellDelegate respondsToSelector:@selector(displayAvatarOfMember:atImageView:)]) {
        [self.membersCellDelegate displayAvatarOfMember:user atImageView:cell.avatarImageView];
    }
    cell.usernameLabel.text = user.memberName;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LZMember *user = [self.members objectAtIndex:indexPath.row];
    if ([self.membersCellDelegate respondsToSelector:@selector(didSelectMember:)]) {
        [self.membersCellDelegate didSelectMember:user];
    }
    return YES;
}

#pragma mark - Gesture

- (void)longPressUser:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.membersCollectionView];
    NSIndexPath *indexPath = [self.membersCollectionView indexPathForItemAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"can't not find index path");
    }
    else {
        if ([self.membersCellDelegate respondsToSelector:@selector(didLongPressMember:)]) {
            [self.membersCellDelegate didLongPressMember:self.members[indexPath.row]];
        }
    }
}

@end
