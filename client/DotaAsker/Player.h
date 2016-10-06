#import "User.h"

@interface Player : User
+ (User*)instance;
+ (void)setPlayer: (User*)player;
@end
