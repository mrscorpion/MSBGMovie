//
//  ViewController.m
//  MSBGMovie
//
//  Created by mr.scorpion on 16/4/30.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "LoginViewController.h"

@interface ViewController ()
@property(nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property(nonatomic ,strong) AVAudioSession *avaudioSession;
@property(nonatomic ,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIView *alpaView;
@property (weak, nonatomic) IBOutlet UIButton *regiset;
@property (weak, nonatomic) IBOutlet UIButton *login;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thirdViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fourViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thridLabelWidth;
@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regiset.layer.cornerRadius = 3.0f;
    self.regiset.alpha = 0.4f;
    self.login.layer.cornerRadius = 3.0f;
    self.login.alpha = 0.4f;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    /**
     *  设置其他音乐软件播放的音乐不被打断
     */
    self.avaudioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [self.avaudioSession setCategory:AVAudioSessionCategoryAmbient error:&error];
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"1.mp4" ofType:nil];
    // demo1 - Test
    //    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"demo1.mp4" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    //    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    [_moviePlayer play];
    [_moviePlayer.view setFrame:self.view.bounds];
    [self.view addSubview:_moviePlayer.view];
    _moviePlayer.shouldAutoplay = YES;
    [_moviePlayer setControlStyle:MPMovieControlStyleNone];
    [_moviePlayer setFullscreen:YES];
    [_moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayer];
    
    _alpaView.backgroundColor = [UIColor clearColor];
    [_moviePlayer.view addSubview:_alpaView];
    self.alpaView.frame = self.moviePlayer.view.bounds;
    
    [self setupTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Question1: present其他的界面，这个MPMoviePlayerController没有被释放 内存没减小  通知也一直在监听播放的状态！要怎样处理
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
    [_moviePlayer.view removeFromSuperview];
    _moviePlayer = nil;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

#pragma mark - Notification
- (void)playbackStateChanged
{
    // 取得目前状态
    MPMoviePlaybackState playbackState = [_moviePlayer playbackState];
    // 状态类型
    switch (playbackState) {
        case MPMoviePlaybackStateStopped:
            [_moviePlayer play];
            break;
            
        case MPMoviePlaybackStatePlaying:
            NSLog(@"播放中");
            break;
            
        case MPMoviePlaybackStatePaused:
            [_moviePlayer play];
            break;
            
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"播放被中断");
            break;
            
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"往前快转");
            break;
            
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"往后快转");
            break;
            
        default:
            NSLog(@"无法辨识的状态");
            break;
    }
}

#pragma mark - Actions and Responds
#pragma mark - Configuration
- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.viewWidth.constant = CGRectGetWidth([UIScreen mainScreen].bounds) *4 ;
    self.secondViewLeading.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.thirdViewLeading.constant = CGRectGetWidth([UIScreen mainScreen].bounds) *2;
    self.fourViewLeading.constant = CGRectGetWidth([UIScreen mainScreen].bounds) *3;
    self.firstLabelWidth.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.secondLabelWidth.constant =CGRectGetWidth([UIScreen mainScreen].bounds);
    self.thridLabelWidth.constant = CGRectGetWidth([UIScreen mainScreen].bounds);
}

#pragma mark - ScrollView & PageControl
- (void)pageChanged:(UIPageControl *)pageControl
{
    CGFloat x = (pageControl.currentPage) * [UIScreen mainScreen].bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    double page = self.scrollView.contentOffset.x / self.scrollView.bounds.size.width;
    self.pageControl.currentPage = page;
    
    if (page== - 1) {
        self.pageControl.currentPage = 3;// 序号0 最后1页
    } else if (page == 4) {
        self.pageControl.currentPage = 0; // 最后+1,循环第1页
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self setupTimer];
}

#pragma mark - Timer
- (void)setupTimer
{
    self.timer = [NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(timerChanged) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)timerChanged
{
    int page  = (self.pageControl.currentPage +1) %4;
    self.pageControl.currentPage = page;
    [self pageChanged:self.pageControl];
}

#pragma mark - Status Bar
// 隐藏状态栏
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Login & Register
- (IBAction)loginAction:(UIButton *)sender
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}
- (IBAction)RegisterAction:(UIButton *)sender
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

