//
//  ShareViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "ShareViewController.h"
#import <UMShare/UMShare.h>
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "Config.h"

@interface ShareViewController ()

@property (nonatomic, assign) IBOutlet UIButton *wxButton;
@property (nonatomic, assign) IBOutlet UIButton *wxCircleButton;
@property (nonatomic, assign) IBOutlet UIButton *qqButton;
@property (nonatomic, assign) IBOutlet UIButton *qqZoneButton;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (IBAction)share:(id)sender {
    
    NSInteger tag = ((UIButton *)sender).tag;
    if((tag == 1 || tag == 3) && ![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqqapi://"]]){
        [self alert:@"请先安装QQ"];
        return;
    }
    
    if((tag == 0 || tag == 2) && ![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://"]]){
        [self alert:@"请先安装微信"];
        return;
    }
    
    NSMutableDictionary *shareInfo = nil;
    if([AppDelegate sharedAppDelegate].loginInfo){
        shareInfo = [AppDelegate sharedAppDelegate].loginInfo[@"share_info"];
    } else {
        shareInfo = [NSMutableDictionary dictionary];
        shareInfo[@"title"] = @"小学英语音标点读";
        shareInfo[@"content"] = @"英语音标点读由一线中小学教学名师团队和移动智能应用公司强强联合，推出的专注小学英语音标学习软件。音标是学习英语的基础，扎实的音标功底是学好英语的关键。本应用让你零基础由浅入深学音标，并且通过语音评测技术帮助矫正你的发音。";
        shareInfo[@"url"] = @"";
    }
    
    UMSocialPlatformType platformType = UMSocialPlatformType_WechatSession;
    switch (tag) {
        case 0:
            platformType = UMSocialPlatformType_WechatSession;
            break;
        case 1:
            platformType = UMSocialPlatformType_QQ;
            break;
        case 2:
            platformType = UMSocialPlatformType_WechatTimeLine;
            break;
        case 3:
            platformType = UMSocialPlatformType_Qzone;
            break;
        default:
            break;
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareInfo[@"title"] descr:shareInfo[@"content"] thumImage:[UIImage imageNamed:@"icon_share"]];
    //设置网页地址
    shareObject.webpageUrl = shareInfo[@"url"];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    __weak typeof(self) weakSelf = self;
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSString *msg =@"分享失败";
            if([error userInfo] && [error userInfo][@"message"]){
                msg = [error userInfo][@"message"];
            }
            [weakSelf.view makeToast:msg
                        duration:3.0
                        position:CSToastPositionCenter];
        } else{
            [weakSelf dismissViewControllerAnimated:YES
                                         completion:^{
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kNotiShareSuccess object:nil];
                                         }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
