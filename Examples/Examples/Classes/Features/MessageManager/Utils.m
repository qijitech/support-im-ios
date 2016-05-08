//
//  Utils.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "Utils.h"
#define CD_VERSION @"version"

@implementation Utils

+ (void)logError:(NSError *)error callback:(dispatch_block_t)callback {
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        callback();
    }
}

+ (NSMutableArray *)setToArray:(NSMutableSet *)set {
    return [[NSMutableArray alloc] initWithArray:[set allObjects]];
}

+ (NSString *)md5OfString:(NSString *)s {
    const char *ptr = [s UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];
    
    return output;
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)roundImage:(UIImage *)image toSize:(CGSize)size radius:(float)radius;
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:radius] addClip];
    [image drawInRect:rect];
    UIImage *rounded = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return rounded;
}

+ (void)pickImageFromPhotoLibraryAtController:(UIViewController *)controller {
    UIImagePickerControllerSourceType srcType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:srcType];
    if ([UIImagePickerController isSourceTypeAvailable:srcType] && [mediaTypes count] > 0) {
        UIImagePickerController *ctrler = [[UIImagePickerController alloc] init];
        ctrler.mediaTypes = mediaTypes;
        ctrler.delegate = (id)controller;
        ctrler.allowsEditing = YES;
        ctrler.sourceType = srcType;
        [controller presentViewController:ctrler animated:YES completion:nil];
    }
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIColor *)randomColor {
    CGFloat hue = arc4random() % 256 / 256.0;
    CGFloat saturation = arc4random() % 128 / 256.0 + 0.5;
    CGFloat brightness = arc4random() % 128 / 256.0 + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

+ (NSArray *)reverseArray:(NSArray *)originArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[originArray count]];
    NSEnumerator *enumerator = [originArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

+ (void)runInMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}

+ (void)runInGlobalQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}

+ (void)runAfterSecs:(float)secs block:(void (^)())block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

+ (void)postNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

#pragma mark - view util

+ (UIActivityIndicatorView *)showIndicatorAtView:(UIView *)hookView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(hookView.frame.size.width * 0.5, hookView.frame.size.height * 0.5 - 50);
    [hookView addSubview:indicator];
    [hookView bringSubviewToFront:indicator];
    indicator.hidden = NO;
    [indicator startAnimating];
    return indicator;
}

+ (void)setCellMarginsZero:(UITableViewCell *)cell {
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

+ (void)setTableViewMarginsZero:(UITableView *)view {
    if (SYSTEM_VERSION < 8) {
        if ([view respondsToSelector:@selector(setSeparatorInset:)]) {
            [view setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    else {
        if ([view respondsToSelector:@selector(layoutMargins)]) {
            view.layoutMargins = UIEdgeInsetsZero;
        }
    }
}

+ (void)stopRefreshControl:(UIRefreshControl *)refreshControl {
    if (refreshControl != nil && [[refreshControl class] isSubclassOfClass:[UIRefreshControl class]]) {
        [refreshControl endRefreshing];
    }
}

#pragma mark - AVUtil


+ (NSString *)uuid {
    NSString *chars = @"abcdefghijklmnopgrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    assert(chars.length == 62);
    int len = (int)chars.length;
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i = 0; i < 24; i++) {
        int p = arc4random_uniform(len);
        NSRange range = NSMakeRange(p, 1);
        [result appendString:[chars substringWithRange:range]];
    }
    return result;
}

+ (void)downloadWithUrl:(NSString *)url toPath:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    NSError *error;
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if (error == nil) {
        NSLog(@"writeSucceed");
    }
    else {
        NSLog(@"error when download file");
    }
}

#pragma mark - time

+ (int64_t)int64OfStr:(NSString *)str {
    return [str longLongValue];
}

+ (NSString *)strOfInt64:(int64_t)num {
    return [[NSNumber numberWithLongLong:num] stringValue];
}

#pragma mark - upgrade

+ (NSString *)currentVersion {
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return versionStr;
}

+ (void)upgradeWithBlock:(CDUpgradeBlock)callback {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:CD_VERSION];
    NSString *curVersion = [[self class] currentVersion];
    BOOL upgrade = [version compare:curVersion options:NSNumericSearch] == NSOrderedAscending;
    callback(upgrade, version, curVersion);
    [defaults setObject:curVersion forKey:CD_VERSION];
}

#pragma mark -

+ (BOOL)isPhoneNumber:(NSString *)text {
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    if (error) {
        NSLog(@"error : %@",error);
        return NO;
    }
    NSRange inputRange = NSMakeRange(0, text.length);
    NSArray *matches = [detector matchesInString:text options:0 range:inputRange];
    if (matches.count == 0) {
        return NO;
    }
    NSTextCheckingResult *result = matches[0];
    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length) {
        return YES;
    } else {
        return NO;
    }
}


@end
