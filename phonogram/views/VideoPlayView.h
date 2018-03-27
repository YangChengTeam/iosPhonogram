//
//  VideoPlayView.h
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BaseView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface VideoPlayView : BaseView
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, assign) BOOL isFullScreen;
@property (strong,nonatomic) AVPlayerViewController *moviePlayer;

- (void)setCoverUrl:(NSString *)coverUrl;
- (void)destory;
@end
