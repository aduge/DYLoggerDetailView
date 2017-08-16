
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "DYLoggerDetailWindow.h"
#import "DYLoggerFileTableView.h"


@interface DYLoggerDetailWindow()

@property (nonatomic, strong) UIButton *logBtn; //日志入口按钮
@property (nonatomic, strong) UIView  *bgMaskView; //日志背景view
@property (nonatomic, strong) UIView  *logListView; //展示日志的view
@property (nonatomic, strong) UITapGestureRecognizer *bgMaskTapGesture; //背景点击手势
@property (nonatomic, strong) UIPanGestureRecognizer *windowPanGesture; //UIWindow拖动手势
@property (nonatomic, weak)   UIWindow  *keyWin;    //主UIWindow
@property (nonatomic, assign) CGPoint btnCenterToScreen; //按钮在屏幕上的绝对位置
@property (nonatomic, assign) CGSize btnSize; //按钮的大小
@property (nonatomic, strong) NSString *logFilePath;  //日志文件路径
@end

@implementation DYLoggerDetailWindow
- (instancetype)initWithFrame:(CGRect )frame  logPath:(NSString *)path
{
    self = [super initWithFrame:frame];
    if (self) {
        //获取入口按钮的大小
        _btnSize = frame.size;
        self.backgroundColor = [UIColor clearColor];
        _keyWin = [UIApplication sharedApplication].keyWindow;
        _btnCenterToScreen = self.center;
        _logFilePath = path;
        [self initSubView];
        [self initClickAndPanAction];
        //添加横竖屏监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;

}


//初始化子视图和手势
- (void)initSubView
{
    _logBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _logBtn.frame = CGRectMake(0, 0, _btnSize.width, _btnSize.height);
    [_logBtn setTitle:@"点击显示Log" forState:UIControlStateNormal];
    _logBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _logBtn.layer.cornerRadius = 3;
    [_logBtn setBackgroundColor:[UIColor yellowColor]];
    [_logBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:_logBtn];
    
    _windowPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(winPanGes:)];
    _bgMaskTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgMaskViewTap:)];
    
}

//添加按钮点击和UIWindow拖动事件
- (void)initClickAndPanAction
{
    [_logBtn addTarget:self action:@selector(logBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addGestureRecognizer:_windowPanGesture];
}


//按钮点击事件
- (void)logBtnClick
{
    self.frame = CGRectMake(0,0,kScreenWidth,kScreenHeight);
    [self removeGestureRecognizer:_windowPanGesture];
    _logBtn.center = _btnCenterToScreen;
    
    _bgMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _bgMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [_bgMaskView addGestureRecognizer:_bgMaskTapGesture];
    [self addSubview:_bgMaskView];
    
    _logListView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    _logListView.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
    _logListView.backgroundColor = [UIColor whiteColor];
    
    //日志列表
    
    DYLoggerFileTableView *logFileTV = [[DYLoggerFileTableView alloc] initWithFrame:_logListView.bounds logsDirectory:_logFilePath];

    [_logListView addSubview:logFileTV];
    [self addSubview:_logListView];
}

//UIWindow拖动手势
- (void)winPanGes:(UIPanGestureRecognizer *)pan
{
    CGPoint startTouchPoint;
    CGPoint originCenter;
    if (pan.state == UIGestureRecognizerStateBegan) {
        startTouchPoint = [pan locationInView:_keyWin];
        originCenter = self.center;
    }
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint p = CGPointMake([pan locationInView:_keyWin].x + (originCenter.x- startTouchPoint.x),
                                [pan locationInView:_keyWin].y + (originCenter.y- startTouchPoint.y));
        self.center = p;
        _btnCenterToScreen = p;
    }
    else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateEnded) {
        CGRect rect = self.frame;
        rect.origin.x = MAX(5, rect.origin.x);
        rect.origin.x = MIN(kScreenWidth - 5 - rect.size.width, rect.origin.x);
        rect.origin.y = MAX(69, rect.origin.y);
        rect.origin.y = MIN(kScreenHeight - 48 - 5 - rect.size.height, rect.origin.y);
        
        if (!CGRectEqualToRect(self.frame, rect)) {
            //超出边界
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.frame = rect;
                _btnCenterToScreen = self.center;
            } completion:nil];
        }
    }
   
    
}

//背景view点击手势
- (void)bgMaskViewTap:(UITapGestureRecognizer *)tap
{
    if (_logListView && [_logListView superview]) {
        [_logListView removeFromSuperview];
    }
    if (_bgMaskView && [_bgMaskView superview]) {
        [_bgMaskView removeFromSuperview];
    }
    self.frame = CGRectMake(0,0,_btnSize.width,_btnSize.height);
    self.center = _btnCenterToScreen;
    _logBtn.frame = CGRectMake(0, 0, _btnSize.width, _btnSize.height);
    [self addGestureRecognizer:_windowPanGesture];
}

- (void)showLog
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self makeKeyAndVisible];
        [_keyWin makeKeyWindow];
        self.hidden = NO;
    });
    
}

- (void)dissmissLog
{
    self.hidden = YES;
    
}

- (void)didChangeOrientation:(NSNotification *)notification
{
    
    UIInterfaceOrientation orientaiton = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientaiton == UIInterfaceOrientationLandscapeLeft || orientaiton == UIInterfaceOrientationLandscapeRight) {
        [self dissmissLog];
    }
    else{
        [self showLog];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
