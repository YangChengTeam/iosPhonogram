//
//  LearnViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "LearnViewController.h"
#import "AppDelegate.h"
#import "LearnContentViewController.h"
#import "SwitchView.h"
#import "Config.h"

@interface LearnViewController ()<SwitchViewDelegate>

@property (nonatomic, assign) IBOutlet SwitchView *switchView;

@end

@implementation LearnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.style = UIPageViewControllerTransitionStylePageCurl;
    
    if([AppDelegate sharedAppDelegate].phoneticList){
        [self initPageViewController];
        return;
    } else {
       [self show:@"正在加载"];
       [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setupPhoneticList:)
                                                     name:kNotiPhoneticListLoadCompleted
                                                   object:nil];
    }
    
}

- (void)setupPhoneticList:(NSNotification *)noti {
    [self  dismiss:nil];
    [self initPageViewController];
}

- (void)initDatasource {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.switchView.count = [[AppDelegate sharedAppDelegate].phoneticList count];
    self.switchView.delegate = self;
    [self.switchView setIndexInfo:0];
    self.datasource = [NSMutableArray array];
    for (NSDictionary *phoneticInfo in [AppDelegate sharedAppDelegate].phoneticList) {
        LearnContentViewController *learnContentVC = [storyboard instantiateViewControllerWithIdentifier:@"learnContent"];
        learnContentVC.phoneticInfo = phoneticInfo;
        [self.datasource addObject:learnContentVC];
    }
}

- (void)switchPage:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[self.datasource[index]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        if(finished) {
            weakSelf.pageViewController.view.userInteractionEnabled = YES;
        }
    }];
    [self.switchView setIndexInfo:index];
}

- (void)switched:(NSInteger)index {
    [self.switchView setIndexInfo:index];
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
