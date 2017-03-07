//
//  ViewController.h
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Utils.h"

@interface AuthorizationViewController : UIViewController

@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;

@end

