//
//  SplashViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "SplashViewController.h"

#import "AppDelegate.h"
#import "NetUtils.h"
#import "Config.h"
#import "UIAlertView+Block.h"


@interface SplashViewController ()
@end

@implementation SplashViewController {
    NSString *msg;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self playSplashAudio];
    [NetUtils postWithUrl:INIT_URL params:nil callback:^(NSDictionary *data) {
        if(data && [data[@"code"] integerValue] == 1) {
            [AppDelegate sharedAppDelegate].loginInfo = data[@"data"];
        } else {
            msg = data[@"msg"];
            if(!msg){
                msg = [NSString stringWithFormat:@"错误代码:%@", data[@"code"]];
            }
        }
    }];
}

- (void)playLogoAnimation {
    self.logoImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"splash_bg1.jpg"],
                                         [UIImage imageNamed:@"splash_bg2.jpg"],
                                         [UIImage imageNamed:@"splash_bg3.jpg"],
                                         [UIImage imageNamed:@"splash_bg4.jpg"], nil];
    self.logoImageView.animationDuration = 1.0f;
    self.logoImageView.animationRepeatCount = 0;
    [self.logoImageView startAnimating];
}

- (void)playSplashAudio {
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"splash" ofType:@"mp3"];
    [self play:[NSURL fileURLWithPath:filePath]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [self.player play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.player pause];
    [super viewWillDisappear:animated];
}

- (void)redirect2Main {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"main"];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
}

- (void)playing {
     [self playLogoAnimation];
}

- (void)finished {
    if([AppDelegate sharedAppDelegate].loginInfo){
        [self redirect2Main];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@,请联系管理员", msg] message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [alertView showAlertViewWithCompleteBlock:^(NSInteger buttonIndex) {
            exit(0);
        }];
    }
}

- (void)error {
    if([AppDelegate sharedAppDelegate].loginInfo){
        [self redirect2Main];
    }
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
