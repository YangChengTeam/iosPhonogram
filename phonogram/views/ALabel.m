//
//  ALabel.m
//  phonogram
//
//  Created by zhangkai on 2018/3/22.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "ALabel.h"

@implementation ALabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawTextInRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(c, self.outLineWidth);
    
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    
    self.textColor = self.outLineTextColor;
    
    [super drawTextInRect:rect];
    
    self.textColor = self.labelTextColor;
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    
    [super drawTextInRect:rect];
    
}


@end
