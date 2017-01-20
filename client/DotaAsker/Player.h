#import "User.h"

@interface Player : NSObject
+ (User*)instance;
+ (void)setID:(long long) ID;
@end
