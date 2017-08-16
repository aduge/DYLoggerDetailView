

#import "DYLoggerDetailTableView.h"

@interface DYLoggerDetailTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray <NSString *> *logItems;
@property (nonatomic, strong) UITableView *tableView;

@end

#define kHeadHeight 40

@implementation DYLoggerDetailTableView

- (instancetype)initWithFrame:(CGRect)frame logFilePath:(NSString *)path{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect headFrame = frame;
        headFrame.size.height = kHeadHeight;
        UIView *headView = [[UIView alloc] initWithFrame:headFrame];
        headView.backgroundColor = [UIColor yellowColor];
        
        UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeSystem];
        btnBack.frame = CGRectMake(0, 0, kHeadHeight, kHeadHeight);
        [btnBack setTitle:@"返回" forState:UIControlStateNormal];
        btnBack.titleLabel.textColor = [UIColor whiteColor];
        [btnBack addTarget:self action:@selector(actionBack) forControlEvents:UIControlEventTouchUpInside];
        
        [headView addSubview:btnBack];
        
        [self addSubview:headView];
    
        CGRect tableFrame = frame;
        tableFrame.origin.y = kHeadHeight;
        tableFrame.size.height = frame.size.height - kHeadHeight;
        _tableView = [[UITableView alloc] initWithFrame:tableFrame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self addSubview:_tableView];
        
        NSString *logContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        _logItems = [logContent componentsSeparatedByString:@"\n"];
    }
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_logItems count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = [_logItems objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellContent = [_logItems objectAtIndex:indexPath.row];
    
    CGSize size = [cellContent boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}
                                            context:nil].size;
    return size.height + 10;
}

- (void)actionBack {
 
    [self removeFromSuperview];
}

@end
