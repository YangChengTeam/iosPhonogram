//
//  BaseViewController.h
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

#define kColorWithHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]


@interface BaseViewController : UIViewController

@property (nonatomic, strong) MBProgressHUD *hud;

- (void)show:(NSString *)message;
- (void)dismiss:(void (^)(void))callback;
- (void)alert:(NSString *)message;
- (void)showByError:(NSError *)error;

@end
