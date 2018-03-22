//
//  Read2meContentViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "Read2meContentViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kRecordAudioFile @"tempRecord.caf"


@interface Read2meContentViewController ()<AVAudioRecorderDelegate>

@property (nonatomic, assign) IBOutlet UIImageView *processBgImageView;
@property (nonatomic, assign) IBOutlet UIImageView *processBarImageView;

@property (nonatomic, assign) IBOutlet UIImageView *logoImageView;
@property (nonatomic, assign) IBOutlet UIImageView *wordImageView;

@property (nonatomic, assign) IBOutlet UIButton *playButton;

@property (nonatomic, assign) IBOutlet UIView *contentView;


@property (nonatomic, assign) IBOutlet UILabel *processLabel;

@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //音频录音机

@property (nonatomic, assign) IBOutlet NSLayoutConstraint *processBarWidth;

@end

@implementation Read2meContentViewController {
    NSInteger playState;
    NSInteger playCount;
    BOOL isPlaying;
    NSURL *recordUrl;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    playCount = 1;
    if(self.phoneticInfo){
        [self.wordImageView sd_setImageWithURL:[NSURL URLWithString:self.phoneticInfo[@"img"]]
                              placeholderImage:[UIImage imageNamed:@"sample.png"]];
    }
    self.logoImageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"splash_bg1.jpg"],
                                          [UIImage imageNamed:@"splash_bg2.jpg"],
                                          [UIImage imageNamed:@"splash_bg3.jpg"],
                                          [UIImage imageNamed:@"splash_bg4.jpg"], nil];
    self.logoImageView.animationDuration = 1.0f;
    self.logoImageView.animationRepeatCount = 0;
    
    
    [self setAudioSession];
    [self setupAudioRecorder];
}

- (IBAction)playVoice:(id)sender {
    if(sender){
        isPlaying = !isPlaying;
        if(!isPlaying){
            [self reset];
            return;
        }
    }
    if(playCount > 3){
        [self over];
        return;
    }
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"guide_01" ofType:@"mp3"];
    if(playCount == 1) {
        [self.playButton setImage:[UIImage imageNamed:@"reading_icon.png"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"reading_icon.png"] forState:UIControlStateHighlighted];
    } else {
       filePath  = [[NSBundle mainBundle] pathForResource:@"guide_02" ofType:@"mp3"];
    }
    playState = 0;
    [self play:[NSURL fileURLWithPath:filePath]];
}

- (void)reset {
    [self clear];
    [self hideProcessView];
    [self dismiss:nil];
    [self.logoImageView stopAnimating];
    [self.logoImageView setImage:[UIImage imageNamed:@"splash_bg1.png"]];
    [self.playButton setImage:[UIImage imageNamed:@"read_stop_normal_icon.png"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"read_stop_pressed_icon.png"] forState:UIControlStateHighlighted];
    playState = 0;
    isPlaying = NO;
}

- (void)over {
    [self reset];
    playCount = 1;
    self.processLabel.text = @"跟读进读：1/3";
}

- (void)playing {
    if(!isPlaying){
        return;
    }
    if(playState == 2 && !recordUrl){
        [self.logoImageView stopAnimating];
        [self.logoImageView setImage:[UIImage imageNamed:@"user_tape_icon.png"]];
    } else {
        [self.logoImageView setImage:[UIImage imageNamed:@"splash_bg1.png"]];
        [self.logoImageView startAnimating];
    }
    [self.playButton setImage:[UIImage imageNamed:@"read_play_normal_icon.png"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"read_play_pressed_icon.png"] forState:UIControlStateHighlighted];
    self.processLabel.text = [NSString stringWithFormat:@"跟读进读：%ld/3", playCount];
}

- (void)finished {
    if(!isPlaying){
        return;
    }
    if(playState == 0){
        playState = 1;
        [self play:[NSURL URLWithString:self.phoneticInfo[@"voice"]]];
    } else if(playState == 1){
        playState = 2;
        NSString *filePath  = [[NSBundle mainBundle] pathForResource:@"user_tape_tips" ofType:@"mp3"];
        [self play:[NSURL fileURLWithPath:filePath]];
    } else if(playState == 2){
        if(!recordUrl){
            if (![self.audioRecorder isRecording]) {
                [self startRecord];
            }
        } else {
            [self play: recordUrl];
            recordUrl = nil;
            playState = 3;
        }
    } else if(playState == 3){
        playCount += 1;
        [self playVoice: nil];
    }
}

- (void)error {
    [self finished];
}


- (void)processAnimate {
    [self showProcessView];
    self.processBarWidth.constant = 0;
    [UIView animateWithDuration:2.0 animations:^{
        [self.contentView layoutIfNeeded];
    }];
}

- (void)hideProcessView {
    self.processBarImageView.hidden = YES;
    self.processBgImageView.hidden = YES;
    self.processBarWidth.constant = 124;
    [self.contentView layoutIfNeeded];
}

- (void)showProcessView {
    self.processBarImageView.hidden = NO;
    self.processBgImageView.hidden = NO;
}

- (void)startRecord {
    [self show:@"开始跟读..."];
    [self.audioRecorder record];
    [self processAnimate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.audioRecorder stop];
        });
    });
}

- (void)setAudioSession {
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

- (NSURL *)getRecordPath {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent: kRecordAudioFile];
    return [NSURL fileURLWithPath:urlStr];
}


- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

- (AVAudioRecorder *)setupAudioRecorder {
    if (!_audioRecorder) {
        NSURL *url = [self getRecordPath];
        NSDictionary *setting = [self getAudioSetting];
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (error) {
            return nil;
        }
    }
    return _audioRecorder;
}

#pragma mark - 录音机代理方法
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if(flag){
        [self dismiss:nil];
        [self.logoImageView setImage:[UIImage imageNamed:@"splash_bg1.png"]];
        [self.logoImageView startAnimating];
        [self hideProcessView];
        [self play:[NSURL URLWithString:self.phoneticInfo[@"voice"]]];
        recordUrl = [self getRecordPath];
        return;
    }
    [self dismiss:nil];
    [self startRecord];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self over];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
