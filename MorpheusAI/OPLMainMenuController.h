//
//  OPLMainMenuController.h
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "OPLChatViewController.h"
#import "OPLNetManagerViewController.h"


@interface OPLMainMenuController : UIViewController <OPLNetManagerViewControllerDelegate, GCDAsyncSocketDelegate>

@end