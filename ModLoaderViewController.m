#import <UIKit/UIKit.h>
#import "TableViewController.m"
#import "TweakObject.m"

@interface ModLoaderViewController: UIViewController
@property (nonatomic, strong) NSMutableArray *dataArray;
- (instancetype)initWithDataArray:(NSArray *)dataArray;
@end

@implementation ModLoaderViewController

- (instancetype)initWithDataArray:(NSArray *)dataArray {
    self = [super init];
    if (self) {
        _dataArray = [dataArray mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Obtener el color de fondo del sistema
    UIColor *systemBackgroundColor = [UIColor systemBackgroundColor];
    self.view.backgroundColor = systemBackgroundColor;

    [self setupCustomTable];
}

- (void)setupCustomTable {
    TableViewController *tableViewController = [[TableViewController alloc] initWithDataArray:self.dataArray];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    tableViewController.navigationItem.title = @"ModLoader";

    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(closeApp:)];          
    tableViewController.navigationItem.rightBarButtonItem = applyButton;

    [self addChildViewController:navigationController];
    [self.view addSubview:navigationController.view];
    [navigationController didMoveToParentViewController:self];
}

- (void)closeApp:(UIBarButtonItem *)sender {
    exit(0);
}
@end
