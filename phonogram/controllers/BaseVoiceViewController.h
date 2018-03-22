//
//  BaseVoiceViewController.h
//  phonogram
//
//  Created by zhangkai on 2018/3/22.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BaseViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface BaseVoiceViewController : BaseViewController

@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * item;
@property (nonatomic, assign) BOOL isOver;

- (void)play:(NSURL *)url;

- (void)playing;
- (void)finished;
- (void)error;

- (void)clear;

@end
