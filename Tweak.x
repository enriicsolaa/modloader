#import <UIKit/UIKit.h>
#import "Headers.h"
#import "ModLoaderViewController.m"
#import "TweakObject.m"
#import <dlfcn.h>

static NSMutableArray *dataArray; // Definir dataArray como una propiedad estática

%hook UIWindow
- (void)becomeKeyWindow {
    %orig;

    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    tap.minimumPressDuration = 2;
    tap.numberOfTouchesRequired = 2;

    [self addGestureRecognizer:tap];
}

%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIViewController *rootController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        
        ModLoaderViewController *modLoaderController = [[ModLoaderViewController alloc] initWithDataArray:dataArray]; // Pasar dataArray a modLoaderController
        [rootController presentViewController:modLoaderController animated:YES completion:nil];
    }
}
%end

%ctor {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Lee el contenido del archivo JSON
    NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:@"/Frameworks/mlprefs" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
    NSError *error = nil;

    // Parsea el JSON en un array de NSDictionary
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

    if (error) {
        NSLog(@"Error al leer el archivo JSON: %@", error.localizedDescription);
    } else {
        dataArray = [NSMutableArray array]; // Inicializa dataArray
        
        // Itera sobre cada objeto en el array JSON y crea instancias de TweakObject
        for (NSDictionary *jsonObject in jsonArray) {
            NSString *name = jsonObject[@"name"];
            NSString *version = jsonObject[@"version"];
            NSString *path = jsonObject[@"path"];
            BOOL isDependency = [jsonObject[@"isDependency"] boolValue];
            
            TweakObject *tweakObject = [[TweakObject alloc] name:name version:version path:path isDependency:isDependency];
            [dataArray addObject:tweakObject];
        }

        for (TweakObject *tweakObject in dataArray) {
            if (!tweakObject.isDependency) {
              if ([defaults objectForKey:tweakObject.name] == nil) {
                [defaults setBool:NO forKey:tweakObject.name];
                [defaults synchronize];
              }

              if ([[defaults objectForKey:tweakObject.name] boolValue] == YES) {
                NSString *pathUrl = [NSString stringWithFormat:@"%s/Frameworks/%s", [[[NSBundle mainBundle] bundlePath] UTF8String], [tweakObject.path UTF8String]];
                dlopen([pathUrl UTF8String], RTLD_NOW);
              }
            }
        }
    }
}