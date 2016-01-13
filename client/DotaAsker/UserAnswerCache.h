//
//  UserAnswerCache.h
//  DotaAsker
//
//  Created by Artem on 20/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import "AbstractCache.h"
@class UserAnswer;

@interface UserAnswerCache : AbstractCache

- (NSArray*)obtainAll;
- (UserAnswer*)obtain:(NSInteger) anID;
- (void)append:(UserAnswer*)userAnswer;
- (void)appendEntities:(NSArray *)entities;
- (UserAnswer*)update:(UserAnswer*)userAnswer;
- (void)remove:(NSInteger) anID;

@end
