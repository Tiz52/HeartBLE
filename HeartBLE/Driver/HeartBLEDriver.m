//
//  HeartBLEDriver.m
//  HeartTestDemo
//
//  Created by 郭志奇 on 2019/8/7.
//  Copyright © 2019 郭志奇. All rights reserved.
//

#import "HeartBLEDriver.h"
#import "HeartBLEDevice.h"
#import "HeartBLEManager.h"

@interface HeartBLEDriver()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    HeartBLEDevice *HeartDevice;
}

@property (nonatomic,strong)NSTimer *scanTimer;

@end

@implementation HeartBLEDriver

+ (HeartBLEDriver *)sharedInstance
{
    static HeartBLEDriver* singleInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[HeartBLEDriver alloc]init];
    });
    return singleInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        dispatch_queue_t queue = dispatch_get_main_queue();
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:nil];
        //[centralManager setDelegate:self];
        
        discoverDevices = [NSMutableArray arrayWithCapacity:1];
        discoverPers = [NSMutableArray arrayWithCapacity:1];
        connectedPeripherals = [NSMutableArray arrayWithCapacity:1];
        connectedDevices = [NSMutableArray arrayWithCapacity:1];
        theFliter = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)setDelegate:(id)delegate{
    theDelegate = delegate;
}


- (BOOL)isBLEPoweredOn{
    return (centralManager.state == CBManagerStatePoweredOn);
}



#pragma mark - Scan

- (void)StartScanForDevice
{
    [discoverDevices removeAllObjects];
    [discoverPers removeAllObjects];
    
    if ([theDelegate respondsToSelector:@selector(onDeviceFound:)]) {
        [theDelegate onDeviceFound:discoverDevices.copy];
    }
    
    if (centralManager.state == CBManagerStateUnsupported) {
        
    }else {
        if (centralManager.state == CBManagerStatePoweredOn) {
            
            [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
        }
    }
}

- (void)stopScan {
    
    [centralManager stopScan];
}


#pragma mark - connect
- (void)connectDevice:(CBPeripheral*)device
{
    if (centralManager.state == CBManagerStateUnsupported)
    {
        
    }
    else
    {
         if (centralManager.state == CBManagerStatePoweredOn && device != nil) {

             [centralManager connectPeripheral:device options:nil];//@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}
         }
    }
}

- (void)disConnectDevice:(CBPeripheral *)peripheral{
    
    if (!peripheral) {
        return;
    }
    
    [centralManager cancelPeripheralConnection:peripheral];
}

- (void)closelAllDevice{
    for (CBPeripheral *per in connectedPeripherals) {
        [centralManager cancelPeripheralConnection:per];
    }
}


#pragma mark - CBCentralManager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"CBCentralManagerStatePoweredOn");
            break;
        case CBManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSArray *arrName = @[@"CL837",@"HW702C",@"sloops",@"SE2", @"CL880"];
   // NSString *NameString = @"CL820W";
    NSString *localName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
//    for (NSString *strA in arrName)
//    {
        if (localName != nil) //[localName rangeOfString:strA].location !=NSNotFound &&
        {
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *Numstr = [formatter stringFromNumber:RSSI];
            
            HeartBLEDevice *Device = [[HeartBLEDevice alloc]initWithPeriphral:peripheral];
            
            Device.DeviceName = localName;
            Device.RSSI = Numstr;
            Device.UUIDStr = peripheral.identifier.UUIDString;
            
            [self addDiscoverDevices:Device];
            [self addDiscoverPers:peripheral];
            
            //代理方法传值
            if ([theDelegate respondsToSelector:@selector(onDeviceFound:)]) {
                [theDelegate onDeviceFound:discoverDevices.copy];
            }
        }
//    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //停止扫描
    [centralManager stopScan];
    
    [self addPeripheral:peripheral];
    
    HeartBLEDevice *device = [self getDeviceWithPeripheral:peripheral];
    
    [self addConnectedDevice:device];
    
    //遵循代理方法 代理回调
    [peripheral setDelegate:device];
    
    [discoverPers removeObject:peripheral];
    [discoverDevices removeObject:device];
    
    if ([theDelegate respondsToSelector:@selector(onDeviceFound:)]) {
        [theDelegate onDeviceFound:discoverDevices.copy];
    }
    // 根据UUID来寻找服务
    [peripheral discoverServices:nil];
    
    //连接设备的参数回调
    if ([theDelegate respondsToSelector:@selector(isConnected:withDevice:)]) {
        [theDelegate isConnected:YES withDevice:device];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    HeartBLEDevice *device = [self getDeviceWithPeripheral:peripheral];
    
    //连接失败的回调
    if ([theDelegate respondsToSelector:@selector(isConnected:withDevice:)]) {
        [theDelegate isConnected:NO withDevice:device];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    HeartBLEDevice *Device = [self getDeviceWithPeripheral:peripheral];
    
    [connectedPeripherals removeObject:peripheral];
    [connectedDevices removeObject:Device];
    
    if ([theDelegate respondsToSelector:@selector(disconnected:)]) {
        [theDelegate disconnected:Device];
    }
}

- (CBPeripheral *)getPeripheralWithDevice:(HeartBLEDevice *)device{
    
    for (CBPeripheral *per in discoverPers) {
        
        if ([per.identifier.UUIDString isEqualToString:device.UUIDStr]) {
            return per;
        }
    }
    for (CBPeripheral *per in connectedPeripherals) {
        if ([per.identifier.UUIDString isEqualToString:device.UUIDStr]) {
            return per;
        }
    }
    return nil;
}

- (HeartBLEDevice *)getDeviceWithPeripheral:(CBPeripheral *)peripheral{
    for (HeartBLEDevice *device in discoverDevices) {
        
        if ([device.UUIDStr isEqualToString:peripheral.identifier.UUIDString]) {
            return device;
        }
    }
    for (HeartBLEDevice *device in connectedDevices) {
        if ([device.UUIDStr isEqualToString:peripheral.identifier.UUIDString]) {
            return device;
        }
    }
    return  nil;
}

- (void)addDiscoverDevices:(HeartBLEDevice *)device
{
    BOOL isExist = NO;
    
    if (discoverDevices.count == 0) {
        [discoverDevices addObject:device];
    }else {
        for (int i = 0;i < discoverDevices.count;i++) {
            HeartBLEDevice *info = [discoverDevices objectAtIndex:i];
            if ([info.UUIDStr isEqualToString:device.UUIDStr]) {
                isExist = YES;
                [discoverDevices replaceObjectAtIndex:i withObject:info];
            }
        }
        if (!isExist) {
            [discoverDevices addObject:device];
        }
    }
}

- (void)addConnectedDevice:(HeartBLEDevice *)device{
    if (![connectedDevices containsObject:device]) {
        [connectedDevices addObject:device];
    }
}

- (void)addDiscoverPers:(CBPeripheral *)peripheral{
    if (![discoverPers containsObject:peripheral]) {
        [discoverPers addObject:peripheral];
    }
}

- (void)addPeripheral:(CBPeripheral *)peripheral {
    if (![connectedPeripherals containsObject:peripheral]) {
        [connectedPeripherals addObject:peripheral];
    }
}

@end
