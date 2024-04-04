#import <Foundation/Foundation.h>

@interface TweakObject : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *version;
@property(nonatomic, strong) NSString *path;
@property(nonatomic, assign) BOOL isDependency;

- (instancetype)name:(NSString *)nameStr
             version:(NSString *)versionStr
                path:(NSString *)pathStr
        isDependency:(BOOL)isDependencyBool;
@end

@implementation TweakObject

- (instancetype)name:(NSString *)nameStr
             version:(NSString *)versionStr
                path:(NSString *)pathStr
        isDependency:(BOOL)isDependencyBool {
  self.name = nameStr;
  self.version = versionStr;
  self.path = pathStr;
  self.isDependency = isDependencyBool;
  return self;
}

@end