//
//  OPLNetManagerController.h
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "OPLNetServiceInspectorViewController.h"

#define OPL_NET_RESOLUTION_TIMEOUT  0.0
#define OPL_SOCKET_NO_TIMEOUT       -1
#define OPL_NET_SERVICE_IDENTIFIER  @"_morpheus._tcp."

@protocol OPLNetManagerViewControllerDelegate;

@interface OPLNetManagerViewController : UITableViewController
<NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic, weak) id<OPLNetManagerViewControllerDelegate> delegate;
@end


@protocol OPLNetManagerViewControllerDelegate <NSObject>
@required
- (void)connectedSocket:(GCDAsyncSocket *)socket;
- (void)resolvedService:(NSNetService *)service;
@end