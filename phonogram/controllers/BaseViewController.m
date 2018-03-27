//
//  BaseViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)show:(NSString *)message {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.label.font = [UIFont systemFontOfSize: 14];
    self.hud.label.text = message;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.hud){
                [self.hud hideAnimated:YES];
                self.hud = nil;
            }
        });
    });
}

- (void)dismiss:(void (^)(void))callback {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        if(callback){
            callback();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.hud){
                [self.hud hideAnimated:YES];
                self.hud = nil;
            }
        });
    });
}

#pragma mark -- alert
- (void)alert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:@"" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alert show];
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
