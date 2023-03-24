//
//  HeartBLEDriver.h
//  HeartTestDemo
//
//  Created by 郭志奇 on 2019/8/7.
//  Copyright © 2019 郭志奇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class HeartBLEDevice;
@protocol BLEDriveDelegate <NSObject>

@optional

- (void)onDeviceFound:(NSArray *)deviceArray;

- (void)isConnected:(BOOL)isConnected withDevice:(HeartBLEDevice *)device;

- (void)disconnected:(HeartBLEDevice *)device;

@end

@class HeartBLEDevice;
@interface HeartBLEDriver : NSObject{
    
    id __weak theDelegate;
    
    CBCentralManager*  centralManager;
    NSMutableArray *discoverDevices;
    
    NSMutableArray *discoverPers;
    
    NSMutableArray *connectedPeripherals;
    
    NSMutableArray *theFliter;
    
@public
    NSMutableArray *connectedDevices;
}

@property (nonatomic,assign)BOOL isBLEPoweredOn;

+ (HeartBLEDriver*)sharedInstance;

- (void)setDelegate:(id)delegate;

- (void)StartScanForDevice;

- (void)stopScan;

- (void)connectDevice: (CBPeripheral*)device;

- (void)disConnectDevice:(CBPeripheral*)device;

- (void)closelAllDevice;

- (void)addDiscoverPers:(CBPeripheral *)peripheral;

- (CBPeripheral *)getPeripheralWithDevice:(HeartBLEDevice *)device;

- (HeartBLEDevice *)getDeviceWithPeripheral:(CBPeripheral *)peripheral;


@end

NS_ASSUME_NONNULL_END
