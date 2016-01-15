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
@property (strong, nonatomic) NSString* entityName;

- (NSData*)obtain:(unsigned long long) entityID;
- (NSData*)obtainAll;
- (NSData*)update:(NSData*) entity;
- (NSData*)create:(NSData*) entity;
- (void)remove:(unsigned long long) entityID;

- (void)sendMessage:(NSString*)message;
- (NSString*)obtainMessageWithMessage:(NSString*)message;

@end
