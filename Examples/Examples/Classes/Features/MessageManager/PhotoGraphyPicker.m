//
//  PhotoGraphyPicker.m
//  SupportIm
//
//  Created by shuu on 16/5/1.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import "PhotoGraphyPicker.h"

@interface PhotoGraphyPicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) DidFinishTakeMediaCompledBlock didFinishTakeMediaCompled;

@end

@implementation PhotoGraphyPicker

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    self.didFinishTakeMediaCompled = nil;
}

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController allowsEditing:(BOOL)allowsEditing compled:(DidFinishTakeMediaCompledBlock)compled {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        compled(nil, nil);
        return;
    }
    self.didFinishTakeMediaCompled = [compled copy];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.navigationBar.barStyle = UIBarStyleBlack;
    imagePickerController.editing = YES;
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = allowsEditing;
    imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    [viewController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType OnViewController:(UIViewController *)viewController completion:(DidFinishTakeImageBlock)completion {
    [self showOnPickerViewControllerSourceType:sourceType onViewController:viewController allowsEditing:YES compled: ^(UIImage *image, NSDictionary *editingInfo) {
        UIImage *edited = editingInfo[UIImagePickerControllerEditedImage];
        UIImage *origin = editingInfo[UIImagePickerControllerOriginalImage];
        UIImage *finalImage = edited ? edited : (origin ? origin : image);
        if (completion) {
            completion(finalImage);
        }
    }];
}

- (void)dismissPickerViewController:(UIImagePickerController *)picker {
    WEAKSELF
    [picker dismissViewControllerAnimated : YES completion : ^{
        weakSelf.didFinishTakeMediaCompled = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    if (self.didFinishTakeMediaCompled) {
        self.didFinishTakeMediaCompled(image, editingInfo);
    }
    [self dismissPickerViewController:picker];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.didFinishTakeMediaCompled) {
        self.didFinishTakeMediaCompled(nil, info);
    }
    [self dismissPickerViewController:picker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}


@end
