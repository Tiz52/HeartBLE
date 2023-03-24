//
//  HeartBLEManager.h
//  HeartTestDemo
//
//  Created by 郭志奇 on 2019/8/7.
//  Copyright © 2019 郭志奇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HeartBLEDevice;
@protocol BLEManagerDelegate <NSObject>

- (void)onDeviceFound:(NSArray *)deviceArray;

- (void)isConnected:(BOOL)isConnected withDevice:(HeartBLEDevice *)device;

- (void)disconnected:(HeartBLEDevice *)device;

@end

@interface HeartBLEManager : NSObject

@property (nonatomic,assign)   BOOL isBLEPoweredOn;

@property (nonatomic,assign)  NSArray *connectedDevices;

+ (instancetype)sharedInstance;

- (void)setDelegate:(id)delegate;

- (void)StartScanDevice;

- (void)stopScan;

- (void)closeAllDevice;
@end

NS_ASSUME_NONNULL_END
