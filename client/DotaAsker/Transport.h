//
//  Transport.h
//  DotaAsker
//
//  Created by Artem on 17/11/15.
//  Copyright © 2015 Artem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFRWebSocket.h"

typedef void(^TransportCompletionBlockData)(NSData*);
typedef void(^TransportCompletionBlockMessage)(NSString*);

@interface Transport : NSObject <JFRWebSocketDelegate>

@property (assign, nonatomic) TransportCompletionBlockData transportCompletionBlockData;
@property (assign, nonatomic) TransportCompletionBlockMessage transportCompletionBlockMessage;
@property (strong, nonatomic) NSString* messageToSend;
@property (strong, nonatomic) NSData* data;
@property (strong, nonatomic) JFRWebSocket* sock;

- (NSArray*)obtainAll;
- (NSData*)obtain:(NSInteger) entityID;
- (id)update:(id) entity;
- (void)remove:(NSInteger) entityID;

- (void)sendMessage:(NSString*)message;
- (NSString*)obtainMessageWithMessage:(NSString*)message;

@end
