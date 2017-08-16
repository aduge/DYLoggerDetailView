

#import "DYLoggerFileTableView.h"
#import "DYLoggerDetailTableView.h"

@interface DYLoggerFileTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *fileNameArr;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation DYLoggerFileTableView

- (instancetype)initWithFrame:(CGRect)frame logsDirectory:(NSString *)directory{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        
        _filePath = directory;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if([fm fileExistsAtPath:_filePath]){
            //取得一个目录下得所有文件名
            _fileNameArr = [fm subpathsAtPath: _filePath];
        }
        
    }
    
    return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_fileNameArr count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = [_fileNameArr objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *subFilePath = [NSString stringWithFormat:@"%@/%@", [NSString stringWithString:_filePath], [_fileNameArr objectAtIndex:indexPath.row]];
    DYLoggerDetailTableView *logDetailTV = [[DYLoggerDetailTableView alloc] initWithFrame:_tableView.bounds logFilePath:subFilePath];
    [self addSubview:logDetailTV];
    
}

@end
