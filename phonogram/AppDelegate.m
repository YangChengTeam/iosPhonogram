//
//  AppDelegate.m
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "AppDelegate.h"
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>
#import <UMShare/UMShare.h>
#import "WXApi.h"
#import "Config.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()<WXApiDelegate>
@end

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [WXApi registerApp:@"wx2d0b6315f8d80d64"];
    [self configUM];
    return YES;
}

- (void)configUM {
    [UMConfigure initWithAppkey:@"5699a62567e58ea1e700160d" channel:@"App Store"];
    [UMConfigure setLogEnabled:SERVER_DEBUG];
    [MobClick setScenarioType:E_UM_NORMAL];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx2d0b6315f8d80d64" appSecret:@"a194bcc16fc8bf38b0bafad7b4f00a4a" redirectURL:@"http://www.upkao.com/"];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106626200"/*设置QQ平台的appID*/  appSecret:@"Vpa3dJ9rkFNy5kyi" redirectURL:@"http://www.upkao.com/"];
}

- (BOOL)isVip {
    BOOL result = NO;
    for(NSDictionary *vipInfo in self.vipList){
        if([vipInfo[@"is_vip"] boolValue]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)isPhoneticListVip {
    BOOL result = NO;
    for(NSDictionary *vipInfo in self.vipList){
        NSInteger vipId = [vipInfo[@"id"] integerValue];
        if((vipId == 4 || vipId == 3 || vipId == 1) && [vipInfo[@"is_vip"] boolValue]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)isPhoneticClassVip {
    BOOL result = NO;
    for(NSDictionary *vipInfo in self.vipList){
        NSInteger vipId = [vipInfo[@"id"] integerValue];
        if((vipId == 4 || vipId == 3 || vipId == 2) && [vipInfo[@"is_vip"] boolValue]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
      BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
    if(!result){
        if ([url.host isEqualToString:@"safepay"]) {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                [self onAlipayResp:resultDic];
            }];
            return result;
        }
        return [WXApi handleOpenURL:url delegate:self];
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if(!result){
        if ([url.host isEqualToString:@"safepay"]) {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                [self onAlipayResp:resultDic];
            }];
            return result;
        }
        return [WXApi handleOpenURL:url delegate:self];
    }
    return result;
}

#pragma mark 微信回调方法
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass: [PayResp class]]){
        PayResp *response = (PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPaySuccess object:nil];
                break;
            default:
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPayFailure object:response];
                break;
        }
    }
}

#pragma mark 支付宝回调方法
- (void)onAlipayResp:(NSDictionary *)resultDic {
    if(resultDic && resultDic[@"resultStatus"] == 0){
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPaySuccess object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPayFailure object:resultDic];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
