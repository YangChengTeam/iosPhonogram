//
//  BaseViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/19.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BasePageViewController.h"
#import "Config.h"
#import "AppDelegate.h"

@interface BasePageViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@end

@implementation BasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.style = UIPageViewControllerTransitionStyleScroll;
}

- (void)initPageViewController {
    [self initDatasource];
    NSDictionary *option = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:10] forKey:UIPageViewControllerOptionInterPageSpacingKey];
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:self.style  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:option];
    
    [self.pageViewController setViewControllers:@[self.datasource[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    [self addChildViewController:self.pageViewController];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.pageContainerView.frame.size.width, self.pageContainerView.frame.size.height);
    [self.pageContainerView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
}

# pragma  mark-- pageViewController datasource
- (NSInteger)indexForViewController:(UIViewController *)controller {
    return [self.datasource indexOfObject:controller];
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    NSInteger index = [self.datasource indexOfObject:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.datasource count]) {
        return nil;
    }
    return self.datasource[index];
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    NSInteger index = [self.datasource indexOfObject:viewController];
    if (index <= 0 || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self.datasource objectAtIndex:index];
}

- (void)showPayViewController:(NSInteger)index {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *popupViewController = [storyboard instantiateViewControllerWithIdentifier:@"pay"];
    popupViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    popupViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.view.window.rootViewController.definesPresentationContext = YES;
    [self.view.window.rootViewController presentViewController:popupViewController animated:YES completion:nil];
}

# pragma mark-- pageViewController delegate
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
//    self.pageViewController.view.userInteractionEnabled = NO;
    self.currentIndex = [self.datasource indexOfObject:[pendingViewControllers firstObject]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
//    self.pageViewController.view.userInteractionEnabled = YES;
    if (completed){
        if([self respondsToSelector:@selector(switched:)]){
            [self switched:self.currentIndex];
        }
    }
}

# pragma mark-- switchView delegate
- (void)switchPage:(NSInteger)index {
    if([self.type isEqualToString:@"list"]){
        if([self checkPhoneticList:index]){
            return;
        }
    } else if([self.type isEqualToString:@"class"]){
        if([self checkPhonetiClass:index]){
            return;
        }
    }
    [self switchPage2:index];
}

- (void)switched:(NSInteger)index {
    [self.switchView setIndexInfo:index];
    if([self.type isEqualToString:@"list"]){
        if([self checkPhoneticList:index]){
            index = kCanUseNumPhoneticList - 1;
            [self switchPage2:index];
        }
    } else if([self.type isEqualToString:@"class"]){
        if([self checkPhonetiClass:index]){
            index = kCanUseNumPhoneticClass - 1;
            [self switchPage2:index];
        }
    }
}

- (void)switchPage2:(NSInteger)index {
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if(self.currentIndex >= index){
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    [self.pageViewController setViewControllers:@[self.datasource[index]] direction:direction animated:YES completion:^(BOOL finished) {
        if(finished) {
            //            weakSelf.pageViewController.view.userInteractionEnabled = YES;
        }
    }];
    [self.switchView setIndexInfo:index];
    self.currentIndex = index;
}

- (BOOL)checkPhoneticList:(NSInteger) index {
    if(index >= kCanUseNumPhoneticList && ![[AppDelegate sharedAppDelegate] isPhoneticListVip]){
        index = kCanUseNumPhoneticList - 1;
        [self showPayViewController:index];
        return YES;
    }
    return NO;
}

- (BOOL)checkPhonetiClass:(NSInteger) index {
    if(index >= kCanUseNumPhoneticClass && ![[AppDelegate sharedAppDelegate] isPhoneticClassVip]){
        index = kCanUseNumPhoneticClass - 1;
        [self showPayViewController:index];
        return YES;
    }
    return NO;
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
