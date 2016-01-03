//
//  AppDelegate.h
//  DotaAsker
//
//  Created by Artem on 07/06/15.
//  Copyright (c) 2015 Artem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//We have to store some of outgoing messages, because:
//This messages are directly impact on game process (Information, that stores in server DB)
//So, we have to be sure, that this type of messages IS delivered to server
//If connection to server will be lost during transmitting, or
//programm will be simply off, we are risking to lost that messages
//for example: Client won match. He sending information to server. Should get some MMR.
//BOOM. Lost connection, no win, no MMR, no match results. BUT.
//Player will be able to replay same round with already known questions. Cheat.
//That's why programm should resend it automatically after reconnecting.

//Or....
//Should it be a BOOL 'Synchronized' property on every data object?...

@property (strong, nonatomic) NSMutableArray *messagesToHost;
- (void)customizeAppearence;
- (void)printAvailableFontNames;
@end

