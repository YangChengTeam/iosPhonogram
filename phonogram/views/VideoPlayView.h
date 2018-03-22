//
//  VideoPlayView.h
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BaseView.h"

@interface VideoPlayView : BaseView
@property (nonatomic, copy) NSString *videoUrl;

- (void)setCoverUrl:(NSString *)coverUrl;
- (void)destory;

@end
