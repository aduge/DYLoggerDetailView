

#import <UIKit/UIKit.h>

@interface DYLoggerDetailWindow : UIWindow
- (instancetype)initWithFrame:(CGRect )frame  logPath:(NSString *)path;
- (void)showLog;
- (void)dissmissLog;
@end
