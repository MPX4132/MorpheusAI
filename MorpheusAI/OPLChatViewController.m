//
//  OPLChatViewController.m
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import "OPLChatViewController.h"

@interface OPLChatViewController () {
    UIAlertView *notConnected;
    NSMutableArray *messages;

    UIColor *greenColor, *blueColor;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)sendMessage:(id)sender;
- (void)addNewMessage:(OPLSimpleMessage *)message;

- (void)hideKeyboard;
- (void)toolbarShift:(BOOL)shift;
- (void)contentShift;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

- (void)socketReadData;
@end


@implementation OPLChatViewController
@synthesize iostream = _iostream;

- (IBAction)sendMessage:(id)sender {
    if ([self.textField.text isEqualToString:@""]) return;

    OPLSimpleMessage *message = [OPLSimpleMessage messageWithContent:self.textField.text
                                                            bySender:@"Local"];

    [self.textField resignFirstResponder];
    [self.textField setText:@""];
    [self addNewMessage:message];
}

- (void)setIostream:(GCDAsyncSocket *)iostream {
    [(_iostream = iostream) setDelegate:self];
}

- (void)addNewMessage:(OPLSimpleMessage *)message {
    [messages addObject:message];
    
    NSIndexPath *newRow = [NSIndexPath indexPathForItem:[self.tableView numberOfRowsInSection:0]
                                              inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[newRow]
                          withRowAnimation:UITableViewRowAnimationAutomatic];

    // If it's for the remote peer, send it out
    if ([message.sender isEqualToString:@"Local"]) {
        NSData *contentData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *data = [NSMutableData dataWithData:contentData];
        [data appendData:[GCDAsyncSocket CRLFData]];
        [self.iostream writeData:data withTimeout:OPL_SOCKET_NO_TIMEOUT
                             tag:0];
    }
}

- (void)hideKeyboard {
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}

- (void)toolbarShift:(BOOL)shift {
    CGSize frameSize = self.view.frame.size;
    CGSize toolbarSize = self.toolbar.frame.size;
    CGPoint newPoint = CGPointMake(frameSize.width/2, frameSize.height);

    if (shift) {
        newPoint.y -= ((toolbarSize.height/2) + OPL_KEYBOARD_VIEW_OFFSET);
    } else {
        newPoint.y -= (toolbarSize.height/2);
    }

    [self.toolbar setCenter:newPoint];
}

- (void)contentShift {
    int cellNumber = (int)[messages count]-1;
    if (cellNumber < 0) return;
     
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:cellNumber inSection:0];

    [self.tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    // work
    [self toolbarShift:YES];

    [UIView commitAnimations];


    [self contentShift];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];

    // work
    [self toolbarShift:NO];

    [UIView commitAnimations];
}

- (void)socketReadData {
    [self.iostream readDataToData:[GCDAsyncSocket CRLFData]
                      withTimeout:OPL_SOCKET_NO_TIMEOUT
                              tag:0];
}


// ================================================================
#pragma mark - UITextField Delegate
// ================================================================
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}


// ================================================================
#pragma mark - Table View Controller
// ================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count]; // Return the number of rows in the section.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OPLSimpleMessage *message = (OPLSimpleMessage *)[messages objectAtIndex:indexPath.row];

    OPLChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Chat Cell"
                                                                 forIndexPath:indexPath];

    UIColor *messageColor = [message.sender isEqualToString:@"Local"] ? blueColor : greenColor;
    [cell.contentView setBackgroundColor:messageColor];


    [cell.textView setTextColor:[UIColor whiteColor]];

    // Configure the cell...
    [cell.textView setText:message.content];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OPLSimpleMessage *message = (OPLSimpleMessage *)[messages objectAtIndex:indexPath.row];

    UITextView *computationLabel = [UITextView new];
    [computationLabel setText:message.content];

    CGFloat textViewWidth = tableView.frame.size.width - (OPL_CELL_TEXT_VIEW_X_PADDING * 2);

    CGSize size = [computationLabel sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    
    return size.height+OPL_CELL_TEXT_VIEW_Y_PADDING;

//    return 52.0f;
}


// ================================================================
#pragma mark - ViewController Methods
// ================================================================
- (void)viewDidLoad {
    [super viewDidLoad];

    messages = [NSMutableArray new];

    float greenIntensity    = 0.75f;
    float blueIntensity     = 0.75f;
    greenColor = [UIColor colorWithRed:(0.0f * greenIntensity /255.0f)
                                 green:(240.0 * greenIntensity /255.0f)
                                  blue:(64.0f * greenIntensity /255.0f)
                                 alpha:1.0];
    blueColor = [UIColor colorWithRed:(33.0f * blueIntensity /255.0f)
                                green:(150.f * blueIntensity /255.0f)
                                 blue:(255.0f * blueIntensity /255.0f)
                                alpha:1.0];

    notConnected = [[UIAlertView alloc] initWithTitle:@"Connection Lost"
                                              message:@"You've been disconnected from the transceiver!"
                                             delegate:NULL
                                    cancelButtonTitle:@"Alright"
                                    otherButtonTitles:nil, nil];

    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    //[self.tableView set]

    UITapGestureRecognizer * tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(hideKeyboard)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [self.tableView addGestureRecognizer:tapRecognizer];


    // Configure the input textfield
    //inputTextfield = [[UITextField alloc] initWithFrame:frame];
    [self.textField setDelegate:self];

    // Dark Keyboard!
    [self.textField setKeyboardAppearance:UIKeyboardAppearanceDark];

    // Only ascii for my sockets!
    //[self.textField setKeyboardType:UIKeyboardTypeASCIICapable];
    [self.textField setReturnKeyType:UIReturnKeyDone];

    // Sets the clear buttton when the text is being editied
    [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];

    // To get the keyboard's notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![self.iostream isConnected])
        [self socketDidDisconnect:self.iostream withError:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self socketReadData];
    
    // Prevent iOS from sleeping
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Allow iOS to sleep
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


// ================================================================
#pragma mark - Socket Delegate
// ================================================================
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // Get message and send the message
    NSString *rawMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSString *remoteMessage = [rawMessage substringToIndex:[rawMessage length]-2];
    OPLSimpleMessage *message = [OPLSimpleMessage messageWithContent:remoteMessage
                                                            bySender:@"Remote"];
    [self addNewMessage:message];

    // To continue reading data
    [self socketReadData];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock
                  withError:(NSError *)err
{
    [notConnected show];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
