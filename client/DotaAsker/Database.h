//
//  Database.h
//  DotaAsker
//
//  Created by Artem on 12/10/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Question;
@class Theme;

@interface Database : NSObject

@property (strong, nonatomic) NSMutableArray *localQuestions;
@property (strong, nonatomic) NSString *kPathToQuestionsFolder;

+ (id)instance;
- (void)loadQuestions;
- (void)onNotificationSynchronizeQuestions:(NSNotification*)aNotification;
- (Question*)questionByID:(NSInteger)questionID;
- (NSMutableArray*)generateQuestionsOnTheme:(Theme*)aTheme;
- (void)removeLocalQuestion:(Question*)question;
- (void)removeLocalQuestions;
- (void)saveLocalQuestions;

@end
