//
//  ConversationDetailViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "ConversationDetailViewController.h"
#import "BaseNavigationController.h"
#import "AddMemberViewController.h"
#import "UserInfoViewController.h"
#import "ConversationNameViewController.h"
#import "ConversationReportAbuseViewController.h"
#import "LZMembersCell.h"

#import "CacheManager.h"
#import "UserManager.h"
#import "LZAlertViewHelper.h"
#import "ChatManager.h"

static NSString *kConvDetailVCTitleKey = @"title";
static NSString *kConvDetailVCDisclosureKey = @"disclosure";
static NSString *kConvDetailVCDetailKey = @"detail";
static NSString *kConvDetailVCSelectorKey = @"selector";
static NSString *kConvDetailVCSwitchKey = @"switch";

static NSString *const reuseIdentifier = @"Cell";

@interface ConversationDetailViewController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, LZMembersCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) LZMembersCell *membersCell;

@property (nonatomic, assign) BOOL own;

@property (nonatomic, strong) NSArray *displayMembers;

@property (nonatomic, strong) UITableViewCell *switchCell;

@property (nonatomic, strong) UISwitch *muteSwitch;

@property (nonatomic, strong) LZAlertViewHelper *alertViewHelper;

@property (nonatomic, strong, readwrite) AVIMConversation *conv;


@end

@implementation ConversationDetailViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kNotificationConversationUpdated object:nil];
    [self setupDatasource];
    [self setupBarButton];
    [self refresh];
}

- (void)setupDatasource {
    NSDictionary *dict1 = @{
                            kConvDetailVCTitleKey : @"举报",
                            kConvDetailVCDisclosureKey : @YES,
                            kConvDetailVCSelectorKey : NSStringFromSelector(@selector(goReportAbuse))
                            };
    NSDictionary *dict2 = @{
                            kConvDetailVCTitleKey : @"消息免打扰",
                            kConvDetailVCSwitchKey : @YES
                            };
    if (self.conv.type == ConversationTypeGroup) {
        self.dataSource = [@[
                             @{
                                 kConvDetailVCTitleKey : @"群聊名称",
                                 kConvDetailVCDisclosureKey : @YES,
                                 kConvDetailVCDetailKey : self.conv.displayName,
                                 kConvDetailVCSelectorKey : NSStringFromSelector(@selector(goChangeName))
                                 },
                             dict2,
                             dict1,
                             @{
                                 kConvDetailVCTitleKey : @"删除并退出",
                                 kConvDetailVCSelectorKey:NSStringFromSelector(@selector(quitConv))
                                 }
                             ] mutableCopy];
    } else {
        self.dataSource = [@[ dict2, dict1 ] mutableCopy];
    }
}

#pragma mark - Propertys

- (UISwitch *)muteSwitch {
    if (_muteSwitch == nil) {
        _muteSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_muteSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_muteSwitch setOn:self.conv.muted];
    }
    return _muteSwitch;
}

/* fetch from memory cache ,it is possible be nil ,if nil, please fetch from server with `refreshCurrentConversation:`*/
- (AVIMConversation *)conv {
    return [[CacheManager manager] currentConversationFromMemory];
}

- (LZAlertViewHelper *)alertViewHelper {
    if (_alertViewHelper == nil) {
        _alertViewHelper = [[LZAlertViewHelper alloc] init];
    }
    return _alertViewHelper;
}

#pragma mark

- (LZMember *)memberFromUser:(AVUser *)user {
    LZMember *member = [[LZMember alloc] init];
    member.memberId = user.objectId;
    member.memberName = user.username;
    return member;
}

- (void)refresh {
    [[CacheManager manager] fetchCurrentConversationIfNeeded:^(AVIMConversation *conversation, NSError *error) {
        if (!error) {
            self.conv  = conversation;
            [self unsafeRefresh];
        } else {
            [self alertError:error];
        }
    }];
}

/*
 * the members of conversation is possiable 0 ,so we call it unsafe
 */
- (void)unsafeRefresh {
    NSAssert(self.conv, @"the conv is nil in the method of `refresh`");
    NSSet *userIds = [NSSet setWithArray:self.conv.members];
    self.own = [self.conv.creator isEqualToString:[AVUser currentUser].objectId];
    self.title = [NSString stringWithFormat:@"详情(%ld人)", (long)self.conv.members.count];
    [self showProgress];
    [[CacheManager manager] cacheUsersWithIds:userIds callback: ^(BOOL succeeded, NSError *error) {
        [self hideProgress];
        if ([self filterError:error]) {
            NSMutableArray *displayMembers = [NSMutableArray array];
            for (NSString *userId in userIds) {
                [displayMembers addObject:[self memberFromUser:[[CacheManager manager] lookupUser:userId]]];
            }
            self.displayMembers = displayMembers;
            [self.tableView reloadData];
        }
    }];
}

- (void)setupBarButton {
    UIBarButtonItem *addMember = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMember)];
    self.navigationItem.rightBarButtonItem = addMember;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationConversationUpdated object:nil];
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.dataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LZMembersCell *cell = [LZMembersCell dequeueOrCreateCellByTableView:tableView];
        cell.members = self.displayMembers;
        cell.membersCellDelegate = self;
        return cell;
    } else {
        UITableViewCell *cell;
        static NSString *identifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        NSDictionary *data = self.dataSource[indexPath.row];
        NSString *title = [data objectForKey:kConvDetailVCTitleKey];
        cell.textLabel.text = title;
        NSString *detail = [data objectForKey:kConvDetailVCDetailKey];
        if (detail) {
            cell.detailTextLabel.text = self.conv.displayName;
        } else {
            cell.detailTextLabel.text = nil;
        }
        BOOL disclosure = [[data objectForKey:kConvDetailVCDisclosureKey] boolValue];
        if (disclosure) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        BOOL isSwitch = [[data objectForKey:kConvDetailVCSwitchKey] boolValue];
        if (isSwitch) {
            cell.accessoryView = self.muteSwitch;
        } else {
            cell.accessoryView = nil;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [LZMembersCell heightForMemberCount:self.displayMembers.count];
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    NSString *selectorName = [[self.dataSource objectAtIndex:indexPath.row] objectForKey:kConvDetailVCSelectorKey];
    if (selectorName) {
        [self performSelector:NSSelectorFromString(selectorName) withObject:nil afterDelay:0];
    }
}

#pragma mark - member cell delegate

- (void)didSelectMember:(LZMember *)member {
    AVUser *user = [[CacheManager manager] lookupUser:member.memberId];
    if ([[AVUser currentUser].objectId isEqualToString:user.objectId] == YES) {
        return;
    }
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)didLongPressMember:(LZMember *)user {
    AVUser *member = [[CacheManager manager] lookupUser:user.memberId];
    NSAssert(member, @"member in `didLongPressMember` is nil");
    if ([member.objectId isEqualToString:self.conv.creator] == NO) {
        [self.alertViewHelper showConfirmAlertViewWithMessage:@"确定要踢走该成员吗？" block:^(BOOL confirm, NSString *text) {
            if (confirm) {
                [self.conv removeMembersWithClientIds:@[ member.objectId ] callback : ^(BOOL succeeded, NSError *error) {
                    if ([self filterError:error]) {
                        [[CacheManager manager] refreshCurrentConversation: ^(BOOL succeeded, NSError *error) {
                            [self alertError:error];
                        }];
                    }
                }];
            }
        }];
    }
}

- (void)displayAvatarOfMember:(LZMember *)member atImageView:(UIImageView *)imageView {
    AVUser *user = [[CacheManager manager] lookupUser:member.memberId];
    [[UserManager manager] displayAvatarOfUser:user avatarView:imageView];
}

#pragma mark - Action

- (void)goReportAbuse {
    ConversationReportAbuseViewController *reportAbuseVC = [[ConversationReportAbuseViewController alloc] initWithConversationId:self.conv.conversationId];
    [self.navigationController pushViewController:reportAbuseVC animated:YES];
}

- (void)switchValueChanged:(UISwitch *)theSwitch {
    AVBooleanResultBlock block = ^(BOOL succeeded, NSError *error) {
        [self alertError:error];
    };
    if ([theSwitch isOn]) {
        [self.conv muteWithCallback:block];
    }
    else {
        [self.conv unmuteWithCallback:block];
    }
}

- (void)goChangeName {
    ConversationNameViewController *vc = [[ConversationNameViewController alloc] init];
    vc.detailVC = self;
    vc.conv = self.conv;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)addMember {
    AddMemberViewController *controller = [[AddMemberViewController alloc] init];
    controller.groupDetailVC = self;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)quitConv {
    [self.conv quitWithCallback: ^(BOOL succeeded, NSError *error) {
        if ([self filterError:error]) {
            [[ChatManager manager] deleteConversation:self.conv];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}


@end
