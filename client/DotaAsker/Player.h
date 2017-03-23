#import "User.h"

@interface Player : NSObject
+ (User*)instance;
+ (void)manualUpdate:(User*)u;
+ (void)manualAddMatch: (Match*)m;
@end
