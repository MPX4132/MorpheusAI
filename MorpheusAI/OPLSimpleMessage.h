//
//  OPLSimpleMessage.h
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPLSimpleMessage : NSObject
@property (nonatomic, readonly, strong) NSString *sender;
@property (nonatomic, readonly, strong) NSString *content;
+ (instancetype)messageWithContent:(NSString *)content bySender:(NSString *)sender;
- (instancetype)init;
@end
