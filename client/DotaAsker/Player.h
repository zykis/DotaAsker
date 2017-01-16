#import "User.h"

@interface Player : NSObject

+ (User*)instance;
+ (void)setPlayer: (User*)player;
@end
