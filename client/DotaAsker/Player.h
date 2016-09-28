#import "User.h"

@interface Player : User
+ (Player*)instance;
- (void)setPlayer: (User*)player;
@end
