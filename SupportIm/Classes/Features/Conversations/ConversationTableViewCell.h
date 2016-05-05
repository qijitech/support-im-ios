//
//  ConversationTableViewCell.h
//  Pods
//
//  Created by shuu on 16/5/5.
//
//

#import <UIKit/UIKit.h>

@interface ConversationTableViewCell : UITableViewCell

+ (CGFloat)heightOfCell;

+ (ConversationTableViewCell *)dequeueOrCreateCellByTableView :(UITableView *)tableView;

+ (void)registerCellToTableView: (UITableView *)tableView ;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageTextLabel;
@property (nonatomic, strong) UILabel *badgeLabel;
//@property (nonatomic, strong) UIView *litteBadgeView;
@property (nonatomic, strong) UILabel *timestampLabel;

@end
