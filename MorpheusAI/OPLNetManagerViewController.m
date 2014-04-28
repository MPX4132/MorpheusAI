//
//  OPLNetManagerViewController.m
//  MorpheusAI
//
//  Created by Matias Barcenas on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import "OPLNetManagerViewController.h"

@interface OPLNetManagerViewController () {
    NSNetServiceBrowser *serviceBrowser;

    UIAlertView *connectionError;
    UIAlertView *resolutionError;
    UIAlertView *scanError;
}

@property (nonatomic, strong) NSMutableArray *services;

- (void)resetServices;
- (void)startScanning;
- (void)stopScanning;

@end

@implementation OPLNetManagerViewController

- (void)resetServices {
    [self stopScanning];
    [self.services removeAllObjects];
}


- (void)startScanning {
    [self resetServices];
    [serviceBrowser searchForServicesOfType:OPL_NET_SERVICE_IDENTIFIER
                                   inDomain:@"local."];
}

- (void)stopScanning {
    [serviceBrowser stop];
}


// ================================================================
#pragma mark - Table View
// ================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.services count]; // Return the number of rows in the section.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Service Cell"
                                                            forIndexPath:indexPath];

    // Configure the cell...
    NSNetService *service = (NSNetService *)[self.services objectAtIndex:indexPath.row];
    [cell.textLabel setText:service.name];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Available";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNetService *service = [self.services objectAtIndex:indexPath.row];
    [service setDelegate:self];
    [service resolveWithTimeout:OPL_NET_RESOLUTION_TIMEOUT];
}


// ================================================================
#pragma mark - NSNetService Delegate
// ================================================================
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
#if DEBUG
    NSLog(@"Resolved successfully.");
#endif
    [self.delegate resolvedService:sender];

    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                                        delegateQueue:dispatch_get_main_queue()];


    // Attempt socket connection
    NSError *errorData;
    for (NSData *ipAddress in sender.addresses) {
        if ([socket connectToAddress:ipAddress error:&errorData]) {
            return; // Upon successfull connection, exit the loop
        }
    }
    [connectionError show];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    NSString *message = [NSString stringWithFormat:@"Resolution for the service \"%@\" was a failure.", sender.name];
    [resolutionError setMessage:message];
    [resolutionError show];
}


// ================================================================
#pragma mark - NSNetServiceBrowser Delegate
// ================================================================
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    [self.services addObject:aNetService];

    // To show the new cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:([self.services count]-1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    long index = [self.services indexOfObject:aNetService];
    [self.services removeObject:aNetService];

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#if DEBUG
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"Will now scan");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    NSLog(@"Scanning stopped");
}
#endif

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
             didNotSearch:(NSDictionary *)errorDict
{
    [scanError show];
}


// ================================================================
#pragma mark - Socket Delegate
// ================================================================
- (void)socket:(GCDAsyncSocket *)sock
didConnectToHost:(NSString *)host
          port:(uint16_t)port
{

#if DEBUG
    NSLog(@"Connected to %@.", host);
#endif
    [self.delegate connectedSocket:sock];
    [self.navigationController popViewControllerAnimated:YES];
}


// ================================================================
#pragma mark - View Controller
// ================================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    [(serviceBrowser = [NSNetServiceBrowser new]) setDelegate:self];

    _services = [NSMutableArray new];

    // ALERT DEFINITIONS
    connectionError = [[UIAlertView alloc] initWithTitle:@"Connection Failed"
                                                 message:@"The connection to the service was a failure.\nTry again later."
                                                delegate:nil
                                       cancelButtonTitle:@"Ok"
                                       otherButtonTitles:nil, nil];

    resolutionError = [[UIAlertView alloc] initWithTitle:@"Resolution Failure"
                                                 message:@""
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil, nil];

    scanError = [[UIAlertView alloc] initWithTitle:@"Scanning Error"
                                           message:@"Unable to scan at this moment.\nPlease try again later."
                                          delegate:nil
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self startScanning];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    OPLNetServiceInspectorViewController *infoController;
    infoController = (OPLNetServiceInspectorViewController *) [segue destinationViewController];

    // Get selected object
    long servicePostion = [self.tableView indexPathForCell:sender].row;
    NSNetService *target = [self.services objectAtIndex:servicePostion];

    [infoController setService:target];
}

@end
