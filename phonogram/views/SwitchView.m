//
//  SwitchView.m
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "SwitchView.h"

@implementation SwitchView {
    NSInteger _index;
    NSTimeInterval currentTime;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)switchPage:(id)sender {
    if ([[NSDate date] timeIntervalSince1970] - currentTime < 0.8) {
        return;
    }
    currentTime = [[NSDate date] timeIntervalSince1970];
    NSInteger tag = ((UIButton *)sender).tag;
    if(tag == 0){
        _index--;
        [self setBtnState];
    } else if(tag == 1){
        _index++;
        [self setBtnState];
    }
    if(self.delegate){
        [self.delegate switchPage:_index];
    }
}

- (void)setBtnState {
    if(_index == 0){
        self.leftBtn.enabled = NO;
        self.rightBtn.enabled = YES;
    } else if(_index == self.count - 1){
        self.rightBtn.enabled = NO;
        self.leftBtn.enabled = YES;
    } else {
        self.leftBtn.enabled = YES;
        self.rightBtn.enabled = YES;
    }
}

- (void)setIndexInfo:(NSInteger)index {
     _index = index;
     [self setBtnState];
     [self.indexBtn setTitle:[NSString stringWithFormat:@"%ld/%ld", _index + 1, self.count] forState:UIControlStateNormal];
}


@end
