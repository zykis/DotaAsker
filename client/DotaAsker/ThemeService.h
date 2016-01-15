//
//  ThemeService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Theme.h"
#import "Round.h"
@import UIKit;

@interface ThemeService : AbstractService
+ (ThemeService*)instance;

- (UIImage*)imageForTheme:(Theme*)theme;
- (Theme*)themeForRound:(Round*)round;

@end
