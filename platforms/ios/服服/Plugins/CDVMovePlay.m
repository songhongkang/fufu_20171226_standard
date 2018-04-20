//
//  CDVMovePlay.m
//  服服
//
//  Created by shangzh on 16/6/30.
//
//

#import "CDVMovePlay.h"
#import <MediaPlayer/MediaPlayer.h>

#define kscreenWidht [UIScreen mainScreen].bounds.size.width

#define kscreenHeight [UIScreen mainScreen].bounds.size.height

@interface CDVMovePlay() <UIScrollViewDelegate>

@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (strong, nonatomic) UIView *container; //播放器容器

@property (nonatomic,strong) UIScrollView *scroll;

@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) UILabel *labelOne;

@property (nonatomic,strong) UILabel *labelTwo;

@property (nonatomic,strong) UILabel *labelThree;

@property (nonatomic,strong) UILabel *labelFour;

//@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器

@end

@implementation CDVMovePlay

- (UIView *)container {
    
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:self.view.bounds];
        _container.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_container];
    }
    return _container;
}

-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem=[self getPlayItem:0];
        _player=[AVPlayer playerWithPlayerItem:playerItem];
        
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.center = CGPointMake(self.view.center.x, self.view.bounds.size.height * 0.9);
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = 4;
        _pageControl.tintColor = [UIColor whiteColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    }
    return _pageControl;
}

- (UILabel *)labelOne {
    if (!_labelOne) {
        _labelOne = [[UILabel alloc] init];
        _labelOne.tag = 1;
        _labelOne.text = @"Label one";
        _labelOne.font = [UIFont systemFontOfSize:16];
        _labelOne.textColor = [UIColor whiteColor];
        [_labelOne sizeToFit];
    }
    return _labelOne;
}

- (UILabel *)labelTwo {
    if (!_labelTwo) {
        _labelTwo = [[UILabel alloc] init];
        _labelTwo.tag = 2;
        _labelTwo.text = @"Label Two";
        _labelTwo.font = [UIFont systemFontOfSize:16];
        _labelTwo.textColor = [UIColor whiteColor];
        [_labelTwo sizeToFit];
        _labelTwo.center = CGPointMake(self.container.center.x, kscreenHeight * 0.8);
    }
    return _labelTwo;
}

- (UILabel *)labelThree {
    if (!_labelThree) {
        _labelThree = [[UILabel alloc] init];
        _labelThree.tag = 3;
        _labelThree.text = @"Label Three";
        _labelThree.font = [UIFont systemFontOfSize:16];
        _labelThree.textColor = [UIColor whiteColor];
        [_labelThree sizeToFit];
        _labelThree.center = CGPointMake(self.container.center.x, kscreenHeight * 0.8);
    }
    return _labelThree;
}

- (UILabel *)labelFour {
    if (!_labelFour) {
        _labelFour = [[UILabel alloc] init];
        _labelFour.tag = 4;
        _labelFour.text = @"Label Four";
        _labelFour.font = [UIFont systemFontOfSize:16];
        _labelFour.textColor = [UIColor whiteColor];
        [_labelFour sizeToFit];
        _labelFour.center = CGPointMake(self.container.center.x, kscreenHeight * 0.8);
    }
    return _labelFour;
}

- (UIScrollView *)scroll {
    if (!_scroll) {
        _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kscreenWidht, kscreenHeight )];
        _scroll.delegate = self;
        _scroll.bounces = NO;
        _scroll.pagingEnabled = YES;
        _scroll.contentSize = CGSizeMake(kscreenWidht * 4, kscreenHeight);
        _scroll.alwaysBounceHorizontal = YES;
    }
    return _scroll;
}

- (void)addsubview {
    self.labelTwo.frame = CGRectMake(kscreenWidht+(kscreenWidht - self.labelTwo.bounds.size.width)/2, kscreenHeight*0.8, self.labelTwo.bounds.size.width, self.labelTwo.bounds.size.height);
    [self.scroll addSubview:self.labelTwo];
    self.labelThree.frame = CGRectMake(kscreenWidht*2+(kscreenWidht - self.labelThree.bounds.size.width)/2, kscreenHeight*0.8, self.labelThree.bounds.size.width, self.labelThree.bounds.size.height);
    [self.scroll addSubview:self.labelThree];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad;{
    [super viewDidLoad];
//    NSLog(@"start paye");
    
    self.labelOne.center = CGPointMake(self.view.center.x, kscreenHeight * 0.8);
    [self.scroll addSubview:self.labelOne];
    
    [self addsubview];
    self.labelFour.frame = CGRectMake(kscreenWidht*3+(kscreenWidht - self.labelFour.bounds.size.width)/2, kscreenHeight*0.8, self.labelFour.bounds.size.width, self.labelFour.bounds.size.height);
    [self.scroll addSubview:self.labelFour];
    
    self.scroll.scrollEnabled = YES;
    
    [self.player play];
  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupUI];
        
    });
//
    
   [self.pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self setupTimer];
    //播放
//    [self.moviePlayer play];
 
    //添加通知
//    [self addNotification];
    
    
}

-(void)setupUI{
    
    //创建播放器层
    AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame=self.container.frame;
    playerLayer.videoGravity=AVLayerVideoGravityResize;//视频填充模式
    [self.container.layer addSublayer:playerLayer];
    
    [self.view addSubview:self.scroll];
    [self.view bringSubviewToFront:self.scroll];
    [self.container addSubview:self.pageControl];
    
    [self addNotification];
}



/**
 *  根据视频索引取得AVPlayerItem对象
 *
 *  @param videoIndex 视频顺序索引
 *
 *  @return AVPlayerItem对象
 */
-(AVPlayerItem *)getPlayItem:(int)videoIndex{
//    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"aaa" ofType:@"mp4"];
    NSString *urlStr = [[NSBundle mainBundle]pathForResource:@"aaa" ofType:@"MOV"];
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
    
    self.view.backgroundColor = [UIColor clearColor];
    
}

#pragma mark - 监控

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        //
    }
}

-(void)pageChanged:(UIPageControl *)pageControl{
    
    CGFloat x = (pageControl.currentPage) * [UIScreen mainScreen].bounds.size.width;

    if (pageControl.currentPage == 3) {
        for (UIView *view in self.scroll.subviews) {
          
            if (view.tag == 2 || view.tag == 3) {
                [view removeFromSuperview];
            }
        }
    } else {
        [self.scroll addSubview:self.labelTwo];
        [self.scroll addSubview:self.labelThree];
    }
    [self.scroll setContentOffset:CGPointMake(x, 0) animated:YES];
    
    
}

- (void)setupTimer {
    self.timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(timerChanged) userInfo:nil repeats:YES];
    
     [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)timerChanged{
    int page  = (self.pageControl.currentPage +1) %4;
    
    self.pageControl.currentPage = page;
    
    [self pageChanged:self.pageControl];
    
}

#pragma mark scorllerView

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    [self.timer invalidate];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    double page = self.scroll.contentOffset.x / self.scroll.bounds.size.width;
    self.pageControl.currentPage = page;
    
    if (page== - 1)
    {

        self.pageControl.currentPage = 3;// 序号0 最后1页
        
    }
    else if (page == 4)
    {
        self.pageControl.currentPage = 0; // 最后+1,循环第1页
        [self.scroll setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [self setupTimer];
    
}
@end
