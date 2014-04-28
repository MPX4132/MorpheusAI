//
//  OPLSimpleMessage.m
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import "OPLSimpleMessage.h"

@implementation OPLSimpleMessage

+ (instancetype)messageWithContent:(NSString *)content bySender:(NSString *)sender {
    return [[OPLSimpleMessage alloc] initWithContent:content bySender:sender];
}

- (instancetype)initWithContent:(NSString *)content bySender:(NSString *)sender {
    if (!(self = [super init])) return NULL;
    _content = [NSString stringWithString:content];
    _sender = [NSString stringWithString:sender];
    return self;
}

- (instancetype)init
{
    return [self initWithContent:@"" bySender:@""];
}
@end
