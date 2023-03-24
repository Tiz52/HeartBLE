//
//  HeartBLEManager.m
//  HeartTestDemo
//
//  Created by 郭志奇 on 2019/8/7.
//  Copyright © 2019 郭志奇. All rights reserved.
//

#import "HeartBLEManager.h"
#import "HeartBLEDevice.h"
#import "HeartBLEDriver.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface HeartBLEManager()<BLEDriveDelegate>
{
    id __weak theDelegate;
    
    HeartBLEDriver*  BLEDriver;
}

@end

@implementation HeartBLEManager

+ (instancetype)sharedInstance{
    static HeartBLEManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[HeartBLEManager alloc]init];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        BLEDriver = [HeartBLEDriver sharedInstance];
        [BLEDriver setDelegate:self];
    }
    return self;
}

#pragma mark - Public Method
- (void)setDelegate:(id)delegate{
    theDelegate = delegate;
}

- (BOOL)isBLEPoweredOn{
    return BLEDriver.isBLEPoweredOn;
}

- (NSArray *)connectedDevices{
    return BLEDriver->connectedDevices.copy;
}

- (void)StartScanDevice
{
    [BLEDriver StartScanForDevice];
}

- (void)stopScan{
    [BLEDriver stopScan];
}

- (void)closeAllDevice{
    [BLEDriver closelAllDevice];
}

#pragma mark - BLEDriverDelegate
- (void)onDeviceFound:(NSArray *)deviceArray{
    
    if ([theDelegate respondsToSelector:@selector(onDeviceFound:)]) {
        [theDelegate onDeviceFound:deviceArray];
    }
}
- (void)isConnected:(BOOL)isConnected withDevice:(HeartBLEDevice *)device{
    if ([theDelegate respondsToSelector:@selector(isConnected:withDevice:)]) {
        [theDelegate isConnected:isConnected withDevice:device];
    }
}
- (void)disconnected:(HeartBLEDevice *)device{
    if ([theDelegate respondsToSelector:@selector(disconnected:)]) {
        [theDelegate disconnected:device];
    }
}


@end
