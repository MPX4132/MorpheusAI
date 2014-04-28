//
//  OPLNetServiceInspectorViewController.m
//  MorpheusAI
//
//  Created by German Z. Jacob F. and Matias B. on 4/13/14.
//  Copyright (c) 2014 Organization of Programming Languages. All rights reserved.
//

#import "OPLNetServiceInspectorViewController.h"

@interface OPLNetServiceInspectorViewController () {
    NSMutableDictionary *info;
    NSMutableArray *keys;
}

- (void)loadServiceInfo:(NSNetService *)service;

@end

@implementation OPLNetServiceInspectorViewController
@synthesize service = _service;

- (void)loadServiceInfo:(NSNetService *)service {
    // If the service is NULL or there are keys, skip everything
    if (!self.service || !keys || !info) return;

    // Make sure these are empty
    [keys removeAllObjects];
    [info removeAllObjects];

    // Give all details
    [keys addObject:@"Descriptor:"];
    [info setObject:service.name forKey:@"Descriptor:"];

    // Some voodoo to format the transport and service
    [keys addObject:@"Service:"];
    NSRange typeRange = [service.type rangeOfString:@"._"];
    NSRange serviceIdentifierRange = NSMakeRange(1, typeRange.location-1);
    NSString *serviceIdentifier = [service.type substringWithRange:serviceIdentifierRange];
    [info setObject:serviceIdentifier forKey:@"Service:"];

    [keys addObject:@"Transport:"];
    long transportStart = typeRange.location+typeRange.length;
    NSRange serviceTransportRange = NSMakeRange(transportStart, [service.type length]-transportStart-1);
    NSString *serviceTransport = [[service.type substringWithRange:serviceTransportRange] uppercaseString];
    [info setObject:serviceTransport forKey:@"Transport:"];

    [keys addObject:@"Domain:"];
    NSString *domain = [service.domain isEqualToString:@"local."] ? @"Local" : service.domain;
    [info setObject:domain forKey:@"Domain:"];

    // Since the service isn't resolved by this point in time, don't show address or port
}


// ================================================================
#pragma mark - Table View
// ================================================================
- (void)setService:(NSNetService *)service {
    [self loadServiceInfo:(_service = service)];
}

- (NSNetService *)service {
    return _service;
}


// ================================================================
#pragma mark - Table View
// ================================================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Return the number of sections.
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [info count]; // Return the number of rows in the section.
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Info Cell"
                                                            forIndexPath:indexPath];

    // Configure the cell...
    NSString *key = [keys objectAtIndex:indexPath.row];
    [cell.textLabel setText:key];
    [cell.detailTextLabel setText:[info objectForKey:key]];

    //[cell setUserInteractionEnabled:NO]; // Don't let the user mess with it!!!

    return cell;
}


// ================================================================
#pragma mark - View Controller
// ================================================================
- (void)viewDidLoad
{
    [super viewDidLoad];
    info = [NSMutableDictionary new];
    keys = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadServiceInfo:self.service];
}

@end
