#import "User.h"

@interface Player : NSObject
+ (User*)instance;
+ (void)manualUpdate:(User*)u;
+ (void)manualAddMatch: (Match*)m;
+ (void)synchronizeWithErrorBlock:(void(^)(NSError* error))errorBlock completionBlock:(void(^)())completionBlock;
@end
