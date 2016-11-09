//
//  PasswordRemindViewController.h
//  DotaAsker
//
//  Created by Artem on 10/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordRemindViewController : UIViewController
- (IBAction)sendNewPassword:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *usernameOrEmail;

@end
