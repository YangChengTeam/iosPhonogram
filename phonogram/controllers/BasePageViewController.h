//
//  BaseViewController.h
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPageViewController+Fix.h"

@interface BasePageViewController : BaseViewController

@property (nonatomic, assign) IBOutlet UIView *pageContainerView;

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableArray *datasource;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) UIPageViewControllerTransitionStyle style;

- (void)initDatasource;
- (void)initPageViewController;
- (void)switched:(NSInteger)index;
@end


