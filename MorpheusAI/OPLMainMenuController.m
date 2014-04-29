//
//  OPLMainMenuController.m
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import "OPLMainMenuController.h"

@interface OPLMainMenuController () {
    NSNetService *resolvedService;
    GCDAsyncSocket *iosocket;
}
@property (strong, nonatomic) IBOutlet UIButton *chatButton;
@property (strong, nonatomic) IBOutlet UIButton *connectButton;

- (void)setInterfaceConnected:(BOOL)connected;

@end

@implementation OPLMainMenuController
- (void)setInterfaceConnected:(BOOL)connected {
    if (connected) {
        [iosocket setDelegate:self];
        [self.connectButton setHidden:YES];
        [self.chatButton setEnabled:YES];
    } else {
        [self.connectButton setHidden:NO];
        [self.chatButton setEnabled:NO];
    }
}

// ================================================================
#pragma mark - OPLNetManagerViewController Delegate
// ================================================================
- (void)resolvedService:(NSNetService *)service {
    resolvedService = service;
}

- (void)connectedSocket:(GCDAsyncSocket *)socket {
    iosocket = socket;
}


// ================================================================
#pragma mark - OPLNetManagerViewController Delegate
// ================================================================
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self setInterfaceConnected:NO];
}


// ================================================================
#pragma mark - ViewController Methods
// ================================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setInterfaceConnected:[iosocket isConnected]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id<NSObject> destination = [segue destinationViewController];

    if ([segue.identifier isEqualToString:@"To Chat"]) {
        OPLChatViewController *chat = (OPLChatViewController *)destination;
        [chat setIostream:iosocket];
    } else
        if ([segue.identifier isEqualToString:@"To Net Manager"]) {
            OPLNetManagerViewController *netManager;
            netManager = (OPLNetManagerViewController *)destination;
            [netManager setDelegate:self];
        }
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return false;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
