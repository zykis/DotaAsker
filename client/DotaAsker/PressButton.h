//
//  PressButton.h
//  DotaAsker
//
//  Created by Artem on 25/11/2016.
//  Copyright © 2016 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PressButton : UIButton
@property (strong, nonatomic) IBInspectable NSString* caption;
@property (strong, nonatomic) IBInspectable UIImage* icon;
@property (nonatomic) IBInspectable NSUInteger fontSize;
@property (nonatomic) IBInspectable CGRect iconRect;

@end
