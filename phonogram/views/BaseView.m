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
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customInit];
}

- (void)customInit {
    NSString *className = self.className;
    if(!className){
        className = NSStringFromClass([self class]);
    }
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    UIView *contentView = [array firstObject];
    [self addSubview:contentView];
}

@end
