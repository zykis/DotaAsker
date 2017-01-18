#import "User.h"

@interface Player : NSObject
+ (User*)instance;
+ (void)setPlayer: (User*)player;
+ (void)setID: long long ID;
@end
