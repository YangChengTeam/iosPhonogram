//
//  BaseView.h
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseView : UIView
@property (nonatomic, copy) NSString *className;

- (void)customInit;

@end
