//
//  ALabel.h
//  phonogram
//
//  Created by zhangkai on 2018/3/22.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALabel : UILabel

/** 描多粗的边*/
@property (nonatomic, assign) NSInteger outLineWidth;

/** 外轮颜色*/
@property (nonatomic, strong) UIColor *outLineTextColor;

/** 里面字体默认颜色*/
@property (nonatomic, strong) UIColor *labelTextColor;

@end
