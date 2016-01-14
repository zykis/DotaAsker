//
//  ThemeService.h
//  DotaAsker
//
//  Created by Artem on 01/01/16.
//  Copyright © 2016 Artem. All rights reserved.
//

#import "AbstractService.h"
#import "Theme.h"
@import UIKit;

@interface ThemeService : AbstractService

- (UIImage*)imageForTheme:(Theme*)theme;

@end
