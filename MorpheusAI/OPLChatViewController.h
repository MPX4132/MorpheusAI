//
//  OPLChatViewController.h
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "OPLSimpleMessage.h"
#import "OPLChatTableViewCell.h"

#define OPL_SOCKET_NO_TIMEOUT -1
#define OPL_KEYBOARD_VIEW_OFFSET 216
#define OPL_CELL_TEXT_VIEW_X_PADDING 36
#define OPL_CELL_TEXT_VIEW_Y_PADDING 8


@interface OPLChatViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, GCDAsyncSocketDelegate, UITextFieldDelegate>
@property (nonatomic, weak) GCDAsyncSocket *iostream; // TCP socket, technically it's a stream
@end
