//
//  UIPageViewController+Fix.m
//  phonogram
//
//  Created by zhangkai on 2018/3/22.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "UIPageViewController+Fix.h"

@implementation UIPageViewController(Fix)

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

@end
