//
//  BaseView.m
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self customInit];
    }
    return self;
}

- (void)customInit {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    UIView *contentView = [array firstObject];
    [self addSubview:contentView];
}

@end
