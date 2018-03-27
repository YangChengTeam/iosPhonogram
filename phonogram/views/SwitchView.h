//
//  SwitchView.h
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"

@protocol SwitchViewDelegate <NSObject>

@required
-(void)switchPage: (NSInteger)index;

@end

@interface SwitchView : BaseView


@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) IBOutlet UIButton *leftBtn;
@property (nonatomic, assign) IBOutlet UIButton *indexBtn;
@property (nonatomic, assign) IBOutlet UIButton *rightBtn;
@property (nonatomic, assign) id<SwitchViewDelegate> delegate;

- (void)setIndexInfo:(NSInteger)index;
- (void)setBtnState;
@end
