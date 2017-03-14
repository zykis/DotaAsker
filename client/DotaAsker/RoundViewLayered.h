//
//  RoundViewLayered.h
//  DotaAsker
//
//  Created by Artem on 10/03/2017.
//  Copyright © 2017 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswerItemView.h"

@class RoundViewLayered;
@protocol RoundViewDelegate <NSObject>

@required
- (void)roundViewAnswerWasTapped:(RoundViewLayered*)roundView atIndex:(NSInteger)index;
@end

@interface RoundViewLayered : UIView <AnswerItemViewDelegate>

@property (strong, nonatomic) CAShapeLayer* shapeLayer;
@property (strong, nonatomic) IBInspectable UIColor* shapeLayerColor;
@property (assign, nonatomic) IBInspectable CGFloat headerWidth;
@property (assign, nonatomic) IBInspectable CGFloat headerHeight;

@property (nonatomic, weak) id <RoundViewDelegate> delegate;

@end
