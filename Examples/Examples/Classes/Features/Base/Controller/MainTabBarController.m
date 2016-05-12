//
//  MainTabBarController.m
//  SupportIm
//
//  Created by shuu on 16/4/25.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "MainTabBarController.h"
#import "MainAccountViewController.h"
#import "ConversationViewController.h"
#import "FriendListViewController.h"
#import "BaseNavigationController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = [UIColor lightGrayColor];
    [self setupControllers];
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.selectedViewController beginAppearanceTransition: YES animated: animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [self.selectedViewController endAppearanceTransition];
}

-(void) viewWillDisappear:(BOOL)animated {
    [self.selectedViewController beginAppearanceTransition: NO animated: animated];
}

-(void) viewDidDisappear:(BOOL)animated {
    [self.selectedViewController endAppearanceTransition];
}



- (void)setupControllers {
    self.tabBar.translucent = NO;
    self.tabBar.tintColor = MAINCOLOR;
    NSArray *controllers = @[
                             [ConversationViewController new],
                             [FriendListViewController new],
                             [MainAccountViewController new],
                             ];
    
    NSArray *titles = @[@"消息", @"通讯录", @"我"];
    NSArray *normalImages = @[@"message", @"contact", @"me"];
    NSArray *selectedImages = @[@"message", @"contact", @"me"];
    
    NSMutableArray *navigationContollers = [NSMutableArray array];
    [controllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger index, BOOL *stop) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        navigationController.navigationBar.barTintColor = MAINCOLOR;
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
//                                     NSFontAttributeName:[UIFont systemFontOfSize:16]
                                     };
        navigationController.navigationBar.titleTextAttributes = attributes;
        NSString *title = titles[index];
        NSString *normalImage = normalImages[index];
        NSString *selectedImage = selectedImages[index];
        UITabBarItem *item = [self createTabBarItemWithTitle:title normalImage:normalImage selectedImage:selectedImage];
        [navigationController setTabBarItem:item];
        [navigationContollers addObject:navigationController];
    }];
    self.viewControllers = [navigationContollers copy];
}

- (UITabBarItem *)createTabBarItemWithTitle:(NSString *)title
                                normalImage:(NSString *)normalImage
                              selectedImage:(NSString *)selectedImage {
    UITabBarItem *item = [UITabBarItem new];
    item.title = title;
    item.image = [UIImage imageNamed:normalImage];
    item.selectedImage = [UIImage imageNamed:selectedImage];
    return item;
}

@end
