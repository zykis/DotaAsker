//
//  AnswerItemView.h
//  DotaAsker
//
//  Created by Artem on 02/07/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnswerItemView;

@protocol AnswerItemViewDelegate <NSObject>

@required
- (void)answerItemViewWasTapped: (AnswerItemView*)answerItemView;
@end

@interface AnswerItemView : UIView
@property (assign, nonatomic) NSInteger answerState;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (assign) id <AnswerItemViewDelegate> delegate;
@end
