//
//  ViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "NetUtils.h"
#import "Config.h"
#import "ShareViewController.h"
#import "UIView+Toast.h"

@interface MainViewController ()

@property (nonatomic, assign) IBOutlet UIButton *centerBtn;
@property (nonatomic, assign) IBOutlet UIButton *indexBtn;
@property (nonatomic, assign) IBOutlet UIButton *learnBtn;
@property (nonatomic, assign) IBOutlet UIButton *read2meBtn;
@property (nonatomic, assign) IBOutlet UIButton *insterestBtn;
@property (nonatomic, assign) IBOutlet UIButton *shareBtn;

@end

@implementation MainViewController {
    NSInteger type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initPageViewController];
    type = 0;
    [NetUtils postWithUrl:PHONOGRAM_LIST_URL params:nil callback:^(NSDictionary *data) {
        if(data && [data[@"code"] integerValue] == 1) {
            [AppDelegate sharedAppDelegate].phoneticList = data[@"data"][@"list"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPhoneticListLoadCompleted object:nil];

        }
    }];
    
    [NetUtils postWithUrl:MCLASS_LIST_URL params:nil callback:^(NSDictionary *data) {
        if(data && [data[@"code"] integerValue] == 1) {
            [AppDelegate sharedAppDelegate].phoneticClass = data[@"data"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPhoneticClassLoadCompleted object:nil];
        }
    }];
    
    [NetUtils postWithUrl:VIP_LIST_URL params:nil callback:^(NSDictionary *data) {
        if(data && [data[@"code"] integerValue] == 1) {
            NSMutableArray *tmpVipList =  [[NSMutableArray alloc] init];
            for(NSDictionary *vipInfo in data[@"data"][@"vip_list"]){
                NSMutableDictionary *tmpVipInfo = [[NSMutableDictionary alloc] initWithDictionary:vipInfo];
                [tmpVipList addObject:tmpVipInfo];
            }
            [AppDelegate sharedAppDelegate].vipList = tmpVipList;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiVipListLoadCompleted object:nil];
             [[NSNotificationCenter defaultCenter] postNotificationName:kNotiVipChange object:nil];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shareSuccess:)
                                                 name:kNotiShareSuccess
                                               object:nil];
}

- (void)shareSuccess:(NSNotification *)sender {
    [self.view makeToast:@"分享成功"
                    duration:3.0
                    position:CSToastPositionCenter];
}

- (void)initDatasource {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *indexViewController = [storyboard instantiateViewControllerWithIdentifier:@"index"];
    UIViewController *learnViewController = [storyboard instantiateViewControllerWithIdentifier:@"learn"];
    UIViewController *read2meViewController = [storyboard instantiateViewControllerWithIdentifier:@"read2me"];
    UIViewController *interestViewController = [storyboard instantiateViewControllerWithIdentifier:@"interest"];
    self.datasource = [NSMutableArray arrayWithArray:@[indexViewController, learnViewController, read2meViewController, interestViewController]];
}

- (void)resetTabState {
    self.indexBtn.selected = false;
    self.learnBtn.selected = false;
    self.read2meBtn.selected = false;
    self.insterestBtn.selected = false;
}

- (void)showShareImage {
    [self.shareBtn setImage:[UIImage imageNamed:@"main_share_selected"] forState:UIControlStateHighlighted];
    [self.shareBtn setImage:[UIImage imageNamed:@"main_share"] forState:UIControlStateNormal];
    type = 0;
}

- (void)showListImage {
    [self.shareBtn setImage:[UIImage imageNamed:@"main_phonogram_view"] forState:UIControlStateNormal];
    [self.shareBtn setImage:[UIImage imageNamed:@"main_phonogram_view_selected"] forState:UIControlStateHighlighted];
    type = 1;
}

- (void)tab:(NSInteger)index {
    [self resetTabState];
    switch (index) {
        case 0:
            self.indexBtn.selected = true;
            [self showShareImage];
            break;
        case 1:
            self.learnBtn.selected = true;
            [self showListImage];
            break;
        case 2:
            self.read2meBtn.selected = true;
            [self showListImage];
            break;
        case 3:
            self.insterestBtn.selected = true;
            [self showShareImage];
            break;
        default:
            break;
    }
}

- (void)switched:(NSInteger)index {
    [self tab: index];
}

- (IBAction)turnPage:(id)sender {
    UIButton *target = (UIButton *)sender;
    __weak typeof(self) weakSelf = self;
    [self.pageViewController setViewControllers:@[self.datasource[target.tag]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        if(finished){
            weakSelf.pageViewController.view.userInteractionEnabled = YES;
        }
    }];
    [self tab:target.tag];
}

- (IBAction)share:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *popupViewController = nil;
    if(type == 0){
        popupViewController = [storyboard instantiateViewControllerWithIdentifier:@"share"];
    } else if(type == 1){
        popupViewController = [storyboard instantiateViewControllerWithIdentifier:@"list"];
    }
    if(!popupViewController){
        return;
    }
    popupViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    popupViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.definesPresentationContext = YES;
    [self presentViewController:popupViewController animated:YES completion:nil];
}

- (IBAction)pay:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *popupViewController = [storyboard instantiateViewControllerWithIdentifier:@"pay"];
    popupViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    popupViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.definesPresentationContext = YES;
    [self presentViewController:popupViewController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}












@end
