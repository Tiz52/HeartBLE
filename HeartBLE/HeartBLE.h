//
//  HeartBLE.h
//  HeartBLE
//
//  Created by Carlos Murillo on 24/03/23.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HeartBLEDevice : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral andCharacteristic:(CBCharacteristic *)characteristic;
- (void)connect;
- (void)disconnect;
- (void)startGetHRWithMode:(NSString *)mode;
- (void)stopGetHR;
- (void)startGetRRWithMode:(NSString *)mode;
- (void)stopGetRR;
- (void)getHisHRWithUTC:(NSString *)UTC;
- (void)getHisRRWithUTC:(NSString *)UTC;
- (void)getUTCWithHR:(NSString *)HR andRR:(NSString *)RR;
- (void)getAll7dayData;
- (void)get7dayDataWithUTC:(NSString *)UTC;
- (void)getTimStepDataWithUTC:(NSString *)UTC andStep:(int)step;
- (void)getSingleTimDataWithUTC:(NSString *)UTC;
- (void)writeData:(NSData *)data;

@end
