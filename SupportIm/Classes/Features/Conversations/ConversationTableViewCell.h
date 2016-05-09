//
//  ConversationTableViewCell.h
//  Pods
//
//  Created by shuu on 16/5/5.
//
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

@interface ConversationTableViewCell : UITableViewCell

+ (CGFloat)heightOfCell;

+ (ConversationTableViewCell *)dequeueOrCreateCellByTableView :(UITableView *)tableView;

+ (void)registerCellToTableView: (UITableView *)tableView ;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageTextLabel;
@property (nonatomic, strong) JSBadgeView *badgeView;
@property (nonatomic, strong) UIView *litteBadgeView;
@property (nonatomic, strong) UILabel *timestampLabel;

@end
