//
//  ViewController.m
//  SupportIm
//
//  Created by shuu on 16/4/23.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "ViewController.h"
#import "MainLoginViewController.h"

#import "MainTabBarController.h"


@interface ViewController ()

@end

@implementation ViewController

# pragma mark - initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *infoLabel = [[UILabel alloc] init];
    [self.view addSubview:infoLabel];
    infoLabel.text = @"IM DEMO";
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.font = [UIFont systemFontOfSize:20.f];
    infoLabel.textColor = [UIColor darkGrayColor];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.left.right.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        /*------ LoginViewController ------*/
        
        MainLoginViewController *mainLoginViewController = [[MainLoginViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainLoginViewController];
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        navigationController.navigationBar.barTintColor = MAINCOLOR;
        [UIView transitionWithView:[[[UIApplication sharedApplication] delegate] window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            BOOL oldState=[UIView areAnimationsEnabled];
            [UIView setAnimationsEnabled:NO];
            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigationController];
            [UIView setAnimationsEnabled:oldState];
        } completion:nil];
        
        
        /*------ MainTabBarController -------*/
        
//        MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
//        [UIView transitionWithView:[[[UIApplication sharedApplication] delegate] window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//            BOOL oldState = [UIView areAnimationsEnabled];
//            [UIView setAnimationsEnabled:NO];
//            [[[[UIApplication sharedApplication] delegate] window] setRootViewController:mainTabBarController];
//            [UIView setAnimationsEnabled:oldState];
//        } completion:nil];
    });
}

@end
