//
//  InterestViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "InterestViewController.h"
#import "InterestContentViewController.h"
#import "SwitchView.h"

#import "AppDelegate.h"
#import "Config.h"

@interface InterestViewController ()
@property (nonatomic, assign) IBOutlet UIView *vipInfoView;
@property (nonatomic, assign) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) IBOutlet UITextView *despLabel;
@property (nonatomic, assign) IBOutlet UILabel *realPriceLabel;
@property (nonatomic, assign) IBOutlet UILabel *oldPriceLabel;
@end

@implementation InterestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.vipInfoView.layer.borderWidth = 1.0;
    self.vipInfoView.layer.borderColor = kColorWithHex(0xFFD391).CGColor;
    
    self.style = UIPageViewControllerTransitionStylePageCurl;
    
    if([AppDelegate sharedAppDelegate].phoneticClass){
        [self initPageViewController];
        [self setupVipInfo];
        return;
    } else {
        [self show:@"正在加载"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setupPhoneticClass:)
                                                     name:kNotiPhoneticClassLoadCompleted
                                                   object:nil];
    }
    
}

- (void)setupVipInfo {
    if([AppDelegate sharedAppDelegate].phoneticClass && [AppDelegate sharedAppDelegate].phoneticClass[@"info"]){
        NSDictionary *info = [AppDelegate sharedAppDelegate].phoneticClass[@"info"];
        self.titleLabel.text = info[@"title"];
        self.despLabel.text = info[@"sub_title"];
        
        NSString *realPriceStr =  [NSString stringWithFormat:@"迎新年特价%@元", info[@"real_price"]];
        NSMutableAttributedString *realPriceAttr = [[NSMutableAttributedString alloc]initWithString: realPriceStr];
        NSRange realPriceStrRange = {5,[realPriceStr length] - 6};
        [realPriceAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range: realPriceStrRange];
        [realPriceAttr addAttribute:NSForegroundColorAttributeName value:kColorWithHex(0xff0000) range: realPriceStrRange];
        self.realPriceLabel.attributedText = realPriceAttr;
        
        NSString *oldPriceStr = [NSString stringWithFormat:@"原价%@元", info[@"price"]];
        NSMutableAttributedString *oldPriceAttr = [[NSMutableAttributedString alloc]initWithString: oldPriceStr];
        NSRange oldPriceStrRange = {0, [oldPriceStr length]};
        [oldPriceAttr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range: oldPriceStrRange];
        self.oldPriceLabel.attributedText = oldPriceAttr;
    }
}

- (void)setupPhoneticClass:(NSNotification *)noti {
    [self dismiss:nil];
    [self initPageViewController];
    [self setupVipInfo];
}

- (void)initDatasource {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.switchView.count = [[AppDelegate sharedAppDelegate].phoneticClass[@"list"] count];
    self.switchView.delegate = self;
    [self.switchView setIndexInfo:0];
    self.datasource = [NSMutableArray array];
    for (NSDictionary *classInfo in [AppDelegate sharedAppDelegate].phoneticClass[@"list"]) {
        InterestContentViewController *interestContentVC = [storyboard instantiateViewControllerWithIdentifier:@"interestContent"];
        interestContentVC.classInfo = classInfo;
        [self.datasource addObject:interestContentVC];
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
