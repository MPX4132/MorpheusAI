//
//  OPLChatTableViewCell.m
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/14/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import "OPLChatTableViewCell.h"

@implementation OPLChatTableViewCell
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect newFrame = self.textView.frame;
    newFrame.size.height = frame.size.height - (newFrame.origin.y*2);
    [self.textView setFrame:newFrame];
}
@end
