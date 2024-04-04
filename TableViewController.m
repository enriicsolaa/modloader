#import <UIKit/UIKit.h>
#import "TweakObject.m"

@interface TableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
- (instancetype)initWithDataArray:(NSArray *)dataArray;
@end

@implementation TableViewController

- (instancetype)initWithDataArray:(NSArray *)dataArray {
    self = [super init];
    if (self) {
        _dataArray = [dataArray mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Crear una instancia de UITableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // Registrar la clase de celda para la tabla
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Devolver el número de secciones en función de si hay dependencias o no
    return [self hasDependencies] ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // Devolver el número de celdas en función de si hay dependencias o no
        return [self tweakCount];
    } else {
        // Si hay dependencias, la sección 1 será para las celdas con el interruptor en "YES"
        return [self dependenciesCount];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Devolver el título de la sección
    return (section == 0) ? @"Tweaks" : @"Dependencies";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.section == 0) {
        // Si la sección es 0, mostrar las celdas de dependencias
        TweakObject *tweak = [self tweakAtIndex:indexPath.row];
        [self configureCell:cell withTweak:tweak];
    } else {
        // Si la sección es 1, mostrar las celdas con el interruptor en "YES"
        TweakObject *tweak = [self dependencyAtIndex:indexPath.row];
        [self configureCell:cell withTweak:tweak];
    }
    
    return cell;
}

#pragma mark - Private Methods

- (void)configureCell:(UITableViewCell *)cell withTweak:(TweakObject *)tweak {
    UISwitch *switchView = [[UISwitch alloc] init];
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    switchView.tag = [self.dataArray indexOfObject:tweak]; // Obtener el índice del tweak
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    cell.textLabel.text = tweak.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (tweak.isDependency) {
        // Si es una dependencia, deshabilitar el interruptor
        cell.textLabel.textColor = [UIColor grayColor];
        switchView.userInteractionEnabled = NO;
        switchView.enabled = NO;
        switchView.on = YES;
    } else {
        // Si no es una dependencia, configurar el interruptor según el estado almacenado
        if ([[defaults objectForKey:tweak.name] boolValue]) {
            switchView.on = YES;
            switchView.userInteractionEnabled = YES;
        } else {
            switchView.on = NO;
            switchView.userInteractionEnabled = YES;
        }
    }
    
    cell.accessoryView = switchView;
}

- (BOOL)hasDependencies {
    // Comprobar si hay dependencias presentes en el dataArray
    for (TweakObject *tweak in self.dataArray) {
        if (tweak.isDependency) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)dependenciesCount {
    // Contar el número de dependencias en el dataArray
    NSUInteger count = 0;
    for (TweakObject *tweak in self.dataArray) {
        if (tweak.isDependency) {
            count++;
        }
    }
    return count;
}

- (NSUInteger)tweakCount {
    // Contar el número de tweaks con el interruptor en "YES" en el dataArray
    NSUInteger count = 0;
    for (TweakObject *tweak in self.dataArray) {
        if (!tweak.isDependency) {
            count++;
        }
    }
    return count;
}

- (TweakObject *)dependencyAtIndex:(NSUInteger)index {
    // Obtener la dependencia en el índice especificado
    NSUInteger count = 0;
    for (TweakObject *tweak in self.dataArray) {
        if (tweak.isDependency) {
            if (count == index) {
                return tweak;
            }
            count++;
        }
    }
    return nil;
}

- (TweakObject *)tweakAtIndex:(NSUInteger)index {
    // Obtener el tweak con el interruptor en "YES" en el índice especificado
    NSUInteger count = 0;
    for (TweakObject *tweak in self.dataArray) {
        if (!tweak.isDependency) {
            if (count == index) {
                return tweak;
            }
            count++;
        }
    }
    return nil;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISwitch

- (void)switchChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    TweakObject *tweak = self.dataArray[indexPath.row];
    
    if (sender.isOn) {
        NSLog(@"Switch is ON");
        [defaults setBool:YES forKey:tweak.name];
        [defaults synchronize];
    } else {
        NSLog(@"Switch is OFF");
        [defaults setBool:NO forKey:tweak.name];
        [defaults synchronize];
    }
}

@end