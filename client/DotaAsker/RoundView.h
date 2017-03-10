//
//  RoundView.h
//  DotaAsker
//
//  Created by Artem on 30/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswerItemView.h"

//@class RoundView;
//@protocol RoundViewDelegate <NSObject>
//
//@required
//- (void)roundViewAnswerWasTapped:(RoundView*)roundView atIndex:(NSInteger)index;
//@end

@interface RoundView : UIView <AnswerItemViewDelegate>
//чтобы принимать сообщение о том, что пользователь кликнул по нажатому ответу

@property (strong, nonatomic) UILabel *roundNumberLabel;
@property (strong, nonatomic) UILabel *themeNameLabel;
@property (strong, nonatomic) NSMutableArray *leftAnswerViews;
@property (strong, nonatomic) NSMutableArray *rightAnswerViews;
//@property (assign) id <RoundViewDelegate> delegate;

- (void)setupConstraints;

@end
