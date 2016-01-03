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

@interface Transport : NSObject <JFRWebSocketDelegate>

@property (assign, nonatomic) TransportCompletionBlockData transportCompletionBlockData;
@property (strong, nonatomic) NSString* messageToSend;
@property (strong, nonatomic) NSData* data;
@property (strong, nonatomic) JFRWebSocket* sock;

- (NSArray*)obtainAll;
- (NSData*)obtain:(NSInteger) entityID;
- (id)update:(id) entity;

- (NSData*)obtainDataWithMessage:(NSString*)message;

@end
