//
//  AppDelegate.m
//  Examples
//
//  Created by Hammer on 5/15/16.
//  Copyright © 2016 奇迹空间. All rights reserved.
//

#import "AppDelegate.h"
//#import "CacheManager.h"
#import "ViewController.h"
#import "MainLoginViewController.h"
#import "MainTabBarController.h"
#import <AVOSCloudCrashReporting/AVOSCloudCrashReporting.h>
//#import "IMService.h"
#import <SupportIm/LZPushManager.h>
//
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>


#define AVOSAppID @"QC1CFBP5VsJfXiiHPohJatmg-gzGzoHsz"
#define AVOSAppKey @"dQw3KFUMRMFp4vjn48z8GUDk"


// mine
//#define AVOSAppID @"LXQhO5hvt5IOyYOhmGoFj6YN-gzGzoHsz"
//#define AVOSAppKey @"8n5D7YOWfV0oGcaaPurlYjtG"


// demo
//#define AVOSAppID @"x3o016bxnkpyee7e9pa5pre6efx2dadyerdlcez0wbzhw25g"
//#define AVOSAppKey @"057x24cfdzhffnl3dzk14jh9xo2rq6w1hy1fdzt5tv46ym78"


static const NSString *APIKey = @"67a6a84bac750ce757a66f4c33ecfdc4";


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self setupSupportIm];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.window makeKeyAndVisible];

    ViewController *rootViewController = [[ViewController alloc] init];
    self.window.rootViewController = rootViewController;

    return YES;

}

- (void)setupSupportIm {
//    [MAMapServices sharedServices].apiKey = (NSString *)APIKey;
//    [AMapSearchServices sharedServices].apiKey = (NSString *)APIKey;
    [AddRequest registerSubclass];
    [AbuseReport registerSubclass];
    // Enable Crash Reporting
    [AVOSCloudCrashReporting enable];
    //希望能提供更详细的日志信息，打开日志的方式是在 AVOSCloud 初始化语句之后加上下面这句：
    //Objective-C
#ifndef __OPTIMIZE__
    
    /*------------ !!!!!! important need disable when release version --------*/
    [AVOSCloud setAllLogsEnabled:YES];
    /*------------ !!!!!! important need disable when release version --------*/
    
#endif
    [AVOSCloud setApplicationId:AVOSAppID clientKey:AVOSAppKey];
    [AVOSCloud setLastModifyEnabled:YES];
#ifdef DEBUG
    [AVAnalytics setAnalyticsEnabled:NO];
    [AVOSCloud setVerbosePolicy:kAVVerboseShow];
    [AVLogger addLoggerDomain:AVLoggerDomainIM];
    [AVLogger addLoggerDomain:AVLoggerDomainCURL];
    [AVLogger setLoggerLevelMask:AVLoggerLevelAll];
#endif
    [[LZPushManager manager] registerForRemoteNotification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [AVOSCloud handleRemoteNotificationsWithDeviceToken:deviceToken];
    [[LZPushManager manager] saveInstallationWithDeviceToken:deviceToken userId:[AVUser currentUser].objectId];
}

- (void)toMain {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[CacheManager manager] registerUsers:@[[AVUser currentUser]]];
    [ChatManager manager].userDelegate = [IMService service];
    
//#ifdef DEBUG
//#warning 使用开发证书来推送，方便调试，具体可看这个变量的定义处
//    [ChatManager manager].useDevPushCerticate = YES;
//#endif
    
    [[ChatManager manager] openWithCallback: ^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self toChat];
        } else {
            [IMToastUtil toastWithText:@"login fail"];
            [self toLogin];
        }
    }];
}

- (void)toChat {
    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
    [UIView transitionWithView:[[[UIApplication sharedApplication] delegate] window] duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [[[[UIApplication sharedApplication] delegate] window] setRootViewController:mainTabBarController];
        [UIView setAnimationsEnabled:oldState];
    } completion:nil];
}

- (void)toLogin {
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
}



@end
