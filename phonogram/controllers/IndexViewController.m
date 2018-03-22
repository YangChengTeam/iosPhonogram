//
//  IndexViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "IndexViewController.h"
#import "AppDelegate.h"
#import "NetUtils.h"
#import "Config.h"

@interface IndexViewController ()
@property (nonatomic, assign) IBOutlet UILabel *userLbl;
@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([AppDelegate sharedAppDelegate].loginInfo){
        self.userLbl.text = [NSString stringWithFormat:@"用户名：SE%@",[AppDelegate sharedAppDelegate].loginInfo[@"user_info"][@"user_id"]];
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
