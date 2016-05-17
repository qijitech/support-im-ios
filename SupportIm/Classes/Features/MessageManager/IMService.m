//
//  IMService.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "IMService.h"
#import "CacheManager.h"
#import "Utils.h"
#import "UserManager.h"
#import "ConversationDetailViewController.h"
#import "User.h"
#import "ChatViewController.h"
#import "EmotionUtils.h"
#import "IMToastUtil.h"
#import "AVUser+Custom.h"


@interface IMService ()

@end

@implementation IMService

+ (instancetype)service {
    static IMService *imService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imService = [[IMService alloc] init];
    });
    return imService;
}

#pragma mark - CDUserDelegate delegate

- (void)cacheUserByIds:(NSSet *)userIds block:(AVBooleanResultBlock)block {
    [[CacheManager manager] cacheUsersWithIds:userIds callback:block];
}

- (id<UserModelDelegate>)getUserById:(NSString *)userId {
    User *user = [[User alloc] init];
    AVUser *avUser = [[CacheManager manager] lookupUser:userId];
    NSString *reason = [NSString stringWithFormat:@"class name :%@, line: %@ , %@", @(__PRETTY_FUNCTION__), @(__LINE__), @"avUser can't be nil!"];
    NSAssert(avUser, reason);
    user.userId = userId;
    user.username = avUser.username;
    user.displayName = avUser.displayName;
//    AVFile *avatarFile = [avUser objectForKey:@"avatar"];
    AVFile *avatarFile = [AVFile fileWithURL:avUser.avatar];
    user.avatarUrl = avatarFile.url;
    return user;
}

- (void)pushToChatRoomByConversation:(AVIMConversation *)conversation fromNavigation:(UINavigationController *)navigation completion:(CompletionBlock)completion {
//    [SKToastUtil toastWithText:@"do something"];

//    //如果从单聊聊天界面跳转到单聊页面，根据当前的业务可以认为这两个单聊是同一个页面，则直接 pop 回聊天界面
    for (UIViewController *viewController in navigation.viewControllers) {
        if ([viewController isKindOfClass:[ChatViewController class]] ) {
            AVIMConversation  *conversationInCDChatVC = [(ChatViewController *)viewController conversation];
            if (conversation.members.count == 2 && conversationInCDChatVC.members.count == 2) {
                [navigation popToViewController:viewController animated:YES];
                return;
            }
        }
    }
//    //如果是从类似朋友圈的地方跳转来，则重新 push 到一个新创建的聊天界面
//    AppDelegate *delegate = ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
//    UIWindow *window = delegate.window;
//    
//    
//    UITabBarController *tabbarController = (UITabBarController *)window.rootViewController;
//    ChatViewController *chatVC = [[ChatViewController alloc] initWithConversation:conversation];
//    chatVC.hidesBottomBarWhenPushed = YES;
//    tabbarController.selectedViewController = tabbarController.viewControllers[0];
//    [navigation popToRootViewControllerAnimated:NO];
//    [tabbarController.selectedViewController pushViewController:chatVC animated:YES];
//    completion ? completion(YES, nil) : nil;

//    UITabBarController *tabbarController = (UITabBarController *)[[UIApplication sharedApplication] delegate].window.rootViewController;
//    ChatViewController *chatVC = [[ChatViewController alloc] initWithConversation:conversation];
//    chatVC.hidesBottomBarWhenPushed = YES;
//    tabbarController.selectedViewController = tabbarController.viewControllers[0];
//    [navigation popToRootViewControllerAnimated:NO];
//    [tabbarController.selectedViewController pushViewController:chatVC animated:YES];
//    completion ? completion(YES, nil) : nil;
    
    ChatViewController *chatVC = [[ChatViewController alloc] initWithConversation:conversation];
    chatVC.hidesBottomBarWhenPushed = YES;

    [navigation pushViewController:chatVC animated:YES];
}

- (void)createChatRoomByUserId:(NSString *)userId fromViewController:(BaseViewController *)viewController completion:(CompletionBlock)completion {
    [[ChatManager manager] fetchConversationWithOtherId:userId callback: ^(AVIMConversation *conversation, NSError *error) {
        if ([viewController filterError:error]) {
            [self pushToChatRoomByConversation:conversation fromNavigation:viewController.navigationController completion:completion];
        } else {
            completion ? completion(NO, error) : nil;
        }
    }];
}

# pragma mark - emotion upload

+ (BOOL)saveEmotionFromResource:(NSString *)resource savedName:(NSString *)name error:(NSError *__autoreleasing *)error{
    __block BOOL result;
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:@"gif"];
    if (path == nil)  {
        *error = [NSError errorWithDomain:@"LeanChatLib" code:1 userInfo:@{NSLocalizedDescriptionKey:@"path is nil"}];
        return NO;
    }
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [EmotionUtils findEmotionWithName:name block:^(AVFile *file, NSError *_error) {
        if (error) {
            result = NO;
            *error = _error;
            dispatch_semaphore_signal(sema);
        } else {
            if (file == nil) {
                AVFile *file = [AVFile fileWithName:name contentsAtPath:path];
                AVObject *emoticon = [AVObject objectWithClassName:@"Emotion"];
                [emoticon setObject:name forKey:@"name"];
                [emoticon setObject:file forKey:@"file"];
                [emoticon saveInBackgroundWithBlock:^(BOOL succeeded, NSError *theError) {
                    if (theError) {
                        result = NO;
                        *error = theError;
                    } else {
                        result = YES;
                    }
                    dispatch_semaphore_signal(sema);
                }];
            } else {
                result = YES;
                dispatch_semaphore_signal(sema);
            }
        }
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return result;
}

+ (NSString *)coverPathOfIndex:(NSInteger)index prefix:(NSString *)prefix {
    return [NSString stringWithFormat:@"%@_%ld",prefix, (long)index];
}

+ (void)saveEmotions {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //tusiji
        [self saveEmotionGroupWithPrefix:@"tusiji" maxIndex:15];
        //rabbit
        [self saveEmotionGroupWithPrefix:@"rabbit" maxIndex:22];
    });
}

+ (void)saveEmotionGroupWithPrefix:(NSString *)prefix maxIndex:(NSInteger)maxIndex {
    for (NSInteger i = 0; i <= maxIndex; i++) {
        NSString *name = [self coverPathOfIndex:i prefix:prefix];
        [self saveEmotionFromResource:name savedName:name error:nil];
    }
}


@end
