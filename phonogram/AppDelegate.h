//
//  AppDelegate.h
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) NSDictionary *loginInfo;
@property (nonatomic, strong) NSArray *phoneticList;
@property (nonatomic, strong) NSDictionary *phoneticClass;

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)sharedAppDelegate;

@end

