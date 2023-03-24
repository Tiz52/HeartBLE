//
//  HeartBLEDevice.m
//  HeartTestDemo
//
//  Created by 郭志奇 on 2019/8/7.
//  Copyright © 2019 郭志奇. All rights reserved.
//

#import "HeartBLEDevice.h"
#import "HeartBLEDriver.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface HeartBLEDevice()<BLEDeviceDelegate,CBPeripheralDelegate>{
    
    HeartBLEDriver *HeartDriver;
    
    id __weak theDelegate;
    
    int ComeInDingyue;

    int WriteCount;
    
    NSString *DeviceNameStr;
    
    int ComeHRCount;
    int ComeRRCount;
    
    NSString *HisHRUTCStr;
    NSString *HisRRUTCStr;
    
    BOOL isStopGetParam;
    
//    int JionHRCount;
    int JionRRCount;
    
    int SleepCount;
    
    NSString *SleepUTCStr;

    int HRVCount;

    BOOL ISHeart;
    BOOL ISRRCount;
    
    NSString *modelNameStr;
    
    int FiveMinCount;
    int OnceMinCount;
    
    BOOL is1542Mode;
    BOOL isCL833Mode;
}

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;

@property (nonatomic,strong)NSMutableArray *HisHRArr;
@property (nonatomic,strong)NSMutableArray *HisRRArr;

@property (nonatomic,strong)NSMutableArray *GetUTCHRArr;
@property (nonatomic,strong)NSMutableArray *GetUTCRRArr;

@property (nonatomic,strong)NSMutableArray *Get7dayArr;
@property (nonatomic,strong)NSMutableArray *Get7dayDataArr;

@property (nonatomic,strong)NSMutableArray *GetTimStepArr;
@property (nonatomic,strong)NSMutableArray *GetSingleTimArr;

@property (nonatomic, copy)NSString *FitChenSunStr;

@end

@implementation HeartBLEDevice

- (void)setDelegate:(id)delegate
{
    theDelegate = delegate;
}

- (void)connect
{
    [HeartDriver connectDevice:self.peripheral];
}

- (void)disconncet
{
    [HeartDriver disConnectDevice:self.peripheral];
}


- (instancetype)initWithPeriphral:(id)thePeripheal
{
    self = [super init];
    if (self) {
        _peripheral = thePeripheal;
        HeartDriver = [HeartBLEDriver sharedInstance];

        self.HisHRArr = [NSMutableArray arrayWithCapacity:0];
        self.HisRRArr = [NSMutableArray arrayWithCapacity:0];
        self.GetUTCHRArr = [NSMutableArray arrayWithCapacity:0];
        self.GetUTCRRArr = [NSMutableArray arrayWithCapacity:0];
        
        self.Get7dayArr = [NSMutableArray arrayWithCapacity:0];
        self.Get7dayDataArr = [NSMutableArray arrayWithCapacity:0];
        self.GetTimStepArr = [NSMutableArray arrayWithCapacity:0];
        self.GetSingleTimArr = [NSMutableArray arrayWithCapacity:0];
        //SendBuffCount = 0;
        HRVCount = 0;
        is1542Mode = NO;
        isCL833Mode = NO;
    }
    return self;
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services)
    {
        NSLog(@"所有服务的UUID:%@",service.UUID);
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"AAE28F00-71B5-42A1-8C3C-F9CF6AC969D0"]])//FD00
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) //心率服务
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"1814"]]) //步频服务
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) //电池服务
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]) //设备服务
        {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error
{
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"所有特征：%@", characteristic);
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        
        NSLog(@"特征的UUID:%@",characteristic.UUID);
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AAE28F01-71B5-42A1-8C3C-F9CF6AC969D0"]])//从设备读数据
        {
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
           // [peripheral readValueForCharacteristic:characteristic];
            
            // 订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AAE28F02-71B5-42A1-8C3C-F9CF6AC969D0"]])//写数据到设备
        {
            self.characteristic = characteristic;
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])//心率
        {
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
            //[peripheral readValueForCharacteristic:characteristic];
            
            // 订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]])//从Model Name
        {
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
            [peripheral readValueForCharacteristic:characteristic];
            
            // 订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]])//电池
        {
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
            [peripheral readValueForCharacteristic:characteristic];
            
            // 订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A28"]])//版本
        {
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
            [peripheral readValueForCharacteristic:characteristic];
            
            // 订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AAE21541-71B5-42A1-8C3C-F9CF6AC969D0"]])//读取PPG值
        {
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
          //  [peripheral readValueForCharacteristic:characteristic];
            
            // 订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            is1542Mode = YES;
        }
    }
    
    HeartBLEDevice *device = [HeartDriver getDeviceWithPeripheral:peripheral];
    [theDelegate isConnected:YES withDevice:device];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"error:%@",error);
    }
//    if (characteristic.isNotifying)
    if (peripheral.state == CBPeripheralStateConnected)
    {
        ComeInDingyue++;
        if (ComeInDingyue == 1)
        {
        //838
            NSString *ModelNameStrs = [self HEXToASSCI:characteristic.value];
            if ([ModelNameStrs isEqualToString:@"CL880N"] || [peripheral.name hasPrefix:@"CL837"]) {
                //设置UTC
                NSString *DateStr = [self dateTransformToTimeSp];
                
                int NowActualTime = [DateStr intValue];//Gets the current actual timex
                
                NSString *Data16Str = [self ToHex:NowActualTime];
                
                NSString *UTCStr = @"ff0808";
                NSString *UTCStr1 = [UTCStr stringByAppendingString:Data16Str];
                
                NSLog(@"UTC时间同步%@", UTCStr1);
                
                [self BLEReadData:UTCStr1];
            }
        }
    }
    else
    {
        NSLog(@"Fail...");
    }
}
    
    -(void)asynUTCTime {
        
        NSDate *date = [NSDate date];
        NSTimeInterval ti = [date timeIntervalSince1970];
        NSString *timeStr = [NSString stringWithFormat:@"%f",ti];
        NSLog(@"timeStr:%@",timeStr);
        int time = [timeStr intValue] + 28800;
        NSLog(@"time:%d",time);
        NSString *Data16Str = [self ToHex:time];
        
        NSString *UTCStr = @"ff0808";
        NSString *UTCStr1 = [UTCStr stringByAppendingString:Data16Str];
        
        NSLog(@"设置UTC时间:%@",UTCStr1);
        
        [self BLEReadData:UTCStr1];
        
    }
    

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  //  SendBuffCount++;
    NSData *data = characteristic.value;
    
    NSLog(@"data:%@",data);
    
    HeartBLEDevice *device = [HeartDriver getDeviceWithPeripheral:peripheral];
    
    if ([theDelegate respondsToSelector:@selector(SDKgetInfo:withDevice:)])
    {
        [theDelegate SDKgetInfo:data withDevice:device];
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A28"]])//设备版本
    {
        NSString *IpStr = [self HEXToASSCI:data];
        
        if ([theDelegate respondsToSelector:@selector(SDKDeviceBanBen:)])
        {
            [theDelegate SDKDeviceBanBen:IpStr];
        }
    }
    //判断Model Name
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]])
    {
        NSString *ModelNameStrs = [self HEXToASSCI:data];
        
        modelNameStr = ModelNameStrs;
        
        if ([modelNameStr isEqualToString:@"CL837"] || [modelNameStr isEqualToString:@"CL880N"])
        {
            isCL833Mode = YES;
        }
    }
    uint8_t *buffer_ = (uint8_t *)[data bytes];
    
    if (data != nil)
    {
        //电池
        NSString *Hex16StrDianCi = [self convertDataToHexStr:data];
        
        if (Hex16StrDianCi.length == 2)
        {
            NSString *Hex16StrDianCiSS = [NSString stringWithFormat:@"%lu",strtoul(Hex16StrDianCi.UTF8String, 0, 16)];
            
            if ([theDelegate respondsToSelector:@selector(SDKDianciStr:)])
            {
                [theDelegate SDKDianciStr:Hex16StrDianCiSS];
            }
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])//Heart Rate
        {
            if (buffer_[0] == 0x00) //心率
            {
                if (buffer_[1] != 0)
                {
                    NSString *Hex16Str = [self convertDataToHexStr:data];
                    NSString *strA = [Hex16Str substringWithRange:NSMakeRange(2,2)];
                    NSString *Para1Str = [NSString stringWithFormat:@"%lu",strtoul(strA.UTF8String, 0, 16)];
                    
                    NSMutableArray *rris = [NSMutableArray array];
                    UInt16 length = data.length - 2; //包头和
                    int index = 2;
                    if (length >= 2) {
                        for (int i = 0; i < length; i++) {
                            if (index > length) {
                                break;
                            }
                            int rri = buffer_[index] + buffer_[index+1]*256;
                            [rris addObject:@(rri)];
                            index = index + 2;
                        }
                    }
                    if ([theDelegate respondsToSelector:@selector(SDKFitHeartParamter:RRIs:)])
                    {
                        [theDelegate SDKFitHeartParamter:Para1Str RRIs:[rris copy]];
                    }
                }
                else if (buffer_[0] == 0x55) //心率
                {
                    NSLog(@"心率数据为0啊");
                }
            }
            else
            {
                NSString *Hex16Str = [self convertDataToHexStr:data];
                NSString *strA = [Hex16Str substringWithRange:NSMakeRange(2,2)];
                NSString *Para1Str = [NSString stringWithFormat:@"%lu",strtoul(strA.UTF8String, 0, 16)];
                
                NSMutableArray *rris = [NSMutableArray array];
                UInt16 length = data.length - 2; //包头和
                int index = 2;
                if (length >= 2) {
                    for (int i = 0; i < length; i++) {
                        if (index > length) {
                            break;
                        }
                        int rri = buffer_[index] + buffer_[index+1]*256;
                        [rris addObject:@(rri)];
                        index = index + 2;
                    }
                }
                if ([theDelegate respondsToSelector:@selector(SDKFitHeartParamter:RRIs:)])
                {
                    [theDelegate SDKFitHeartParamter:Para1Str RRIs:[rris copy]];
                }
            }
        }
        else if (buffer_[0] == 0xff)
        {
            if (buffer_[2] == 0x03)
            {
                NSString *Hex16Str = [self convertDataToHexStr:data];
                
                if (Hex16Str.length >= 30)
                {
                    //年龄
                    NSString *OldStr = [Hex16Str substringWithRange:NSMakeRange(10,2)];
                    NSString *OldStrs = [NSString stringWithFormat:@"%lu",strtoul(OldStr.UTF8String, 0, 16)];//十六进制转普通字符串
                    
                    //性别
                    NSString *SexStr = [Hex16Str substringWithRange:NSMakeRange(12,2)];
                    NSString *SexStrs = [NSString stringWithFormat:@"%lu",strtoul(SexStr.UTF8String, 0, 16)];//十六进制转普通字符串
                    
                    //体重
                    NSString *WeiStr = [Hex16Str substringWithRange:NSMakeRange(14,2)];
                    NSString *WeiStrs = [NSString stringWithFormat:@"%lu",strtoul(WeiStr.UTF8String, 0, 16)];//十六进制转普通字符串
                    
                    //身高
                    NSString *HeiStr = [Hex16Str substringWithRange:NSMakeRange(16,2)];
                    NSString *HeiStrs = [NSString stringWithFormat:@"%lu",strtoul(HeiStr.UTF8String, 0, 16)];//十六进制转普通字符串
                    
                    //手机号
                    NSString *PhNumStr = [Hex16Str substringWithRange:NSMakeRange(18,10)];
                    NSString *PhNumStrs = [NSString stringWithFormat:@"%lu",strtoul(PhNumStr.UTF8String, 0, 16)];//十六进制转普通字符串
                    
                    if ([theDelegate respondsToSelector:@selector(SDKUserInfo:andSex:andWeight:andHeight:andPhoneNum:)])
                    {
                        [theDelegate SDKUserInfo:OldStrs andSex:SexStrs andWeight:WeiStrs andHeight:HeiStrs andPhoneNum:PhNumStrs];
                    }
                }
                else
                {
                    NSLog(@"数据长度出错!");
                }
            }
            else if (buffer_[2] == 0x04)
            {
                NSLog(@"设置成功了");
                if ([theDelegate respondsToSelector:@selector(SDKGetUserInfoState:)])
                {
                    [theDelegate SDKGetUserInfoState:@"1"];
                }
            }
            else if (buffer_[2] == 0x15)
            {
                //运动实时数据
                NSString *Hex16Str = [self convertDataToHexStr:data];
             
                if (Hex16Str.length >= 24)
                {
                    //步数
                    NSString *strA = [Hex16Str substringWithRange:NSMakeRange(6,6)];
                    NSString *Para1Str = [NSString stringWithFormat:@"%lu",strtoul(strA.UTF8String, 0, 16)];//十六进制转普通字符串
                    
                    //距离
                    NSString *strB = [Hex16Str substringWithRange:NSMakeRange(12, 6)];
                    NSString *Para2Str = [NSString stringWithFormat:@"%lu",strtoul(strB.UTF8String, 0, 16)];
                    float a = [Para2Str floatValue] / 100;
                    
                    //卡路里
                    NSString *strC = [Hex16Str substringWithRange:NSMakeRange(18, 6)];
                    NSString *Para3Str = [NSString stringWithFormat:@"%lu",strtoul(strC.UTF8String, 0, 16)];
                    float b = [Para3Str floatValue]/10;
                    
                    if ([theDelegate respondsToSelector:@selector(SDKFitRunSParamter:andFitKM:andFitCalor:)]) {
                        [theDelegate SDKFitRunSParamter:[Para1Str intValue] andFitKM:a andFitCalor:b];
                    }
                }
            }
            else if (buffer_[2] == 0x16)
            {
                if (isCL833Mode == YES && is1542Mode == YES)
                {
                    // 7天历史记录  步数  里程 卡路里
                    NSString *Hex16Str = [self convertDataToHexStr:data];
                    
                    NSString *StrLen = [Hex16Str substringWithRange:NSMakeRange(2, 2)];
                    NSString *StrLenS = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                    
                    NSString *DataStr = [Hex16Str substringWithRange:NSMakeRange(6, [StrLenS intValue] * 2 - 8)];
                    
                    NSMutableArray *DataArr = [[NSMutableArray alloc]init];
                    for (int i = 0; i < DataStr.length; i+=20)
                    {
                        NSRange range1 = NSMakeRange(i, 20);
                        NSString *str1 = [DataStr substringWithRange:range1];
                        [DataArr addObject:str1];
                    }
                    
                    NSMutableArray *MainArr = [[NSMutableArray alloc]init];
                    for (NSString *DateStr in DataArr)
                    {
                        NSMutableArray *HisArrSS = [[NSMutableArray alloc]init];
                        
                        //UTC
                        NSString *StrLen = [DateStr substringWithRange:NSMakeRange(0, 8)];
                        NSString *UTCStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                        NSString *UTCStr1 = [self transformTime1:[UTCStr intValue]];
                        
                        [HisArrSS addObject:UTCStr1];
                        //步数
                        NSString *StrLen1 = [DateStr substringWithRange:NSMakeRange(8, 6)];
                        NSString *StepStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen1.UTF8String, 0, 16)];
                        
                        [HisArrSS addObject:StepStr];
                        
                        //c卡路里
                        NSString *StrLen2 = [DateStr substringWithRange:NSMakeRange(14, 6)];
                        NSString *CalorStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen2.UTF8String, 0, 16)];
                        
                        [HisArrSS addObject:CalorStr];
                        
                        [MainArr addObject:HisArrSS];
                        
                    }
                    MainArr = (NSMutableArray *)[[MainArr reverseObjectEnumerator]allObjects];
                    if ([theDelegate respondsToSelector:@selector(SDKGet7DaysHisParam:)])
                    {
                        [theDelegate SDKGet7DaysHisParam:MainArr];
                    }
                }
                else
                {
                    if (buffer_[3] == 0xff)
                    {
                        for (NSString *DateStr in self.Get7dayArr)
                        {
                            NSMutableArray *HisArrSS = [[NSMutableArray alloc]init];
                            
                            if (DateStr.length >= 20)
                            {
                                //UTC
                                NSString *StrLen = [DateStr substringWithRange:NSMakeRange(0, 8)];
                                NSString *UTCStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                                NSString *UTCStr1 = [self transformTime1:[UTCStr intValue]];
                                
                                [HisArrSS addObject:UTCStr1];
                                //步数
                                NSString *StrLen1 = [DateStr substringWithRange:NSMakeRange(8, 6)];
                                NSString *StepStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen1.UTF8String, 0, 16)];
                                   
                                [HisArrSS addObject:StepStr];
                                
                                //c卡路里
                                NSString *StrLen2 = [DateStr substringWithRange:NSMakeRange(14, 6)];
                                NSString *CalorStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen2.UTF8String, 0, 16)];
                                
                                [HisArrSS addObject:CalorStr];
                                
                                [self.Get7dayDataArr addObject:HisArrSS];
                            }
                        }
                        
                        if ([theDelegate respondsToSelector:@selector(SDKGet7DaysHisParam:)])
                        {
                            [theDelegate SDKGet7DaysHisParam:self.Get7dayDataArr];
                        }
                        self.Get7dayArr = [[NSMutableArray alloc]init];
                        self.Get7dayDataArr = [[NSMutableArray alloc]init];
                    }
                    else
                    {
                        // 7天历史记录  步数  里程 卡路里
                        NSString *Hex16Str = [self convertDataToHexStr:data];
                        
                        NSString *StrLen = [Hex16Str substringWithRange:NSMakeRange(2, 2)];
                        NSString *StrLenS = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                        
                        if (Hex16Str.length >= 6+[StrLenS intValue] * 2 - 8)
                        {
                            NSString *DataStr = [Hex16Str substringWithRange:NSMakeRange(6, [StrLenS intValue] * 2 - 8)];
                            
                            for (int i = 0; i < DataStr.length; i+=20)
                            {
                                NSRange range1 = NSMakeRange(i, 20);
                                NSString *str1 = [DataStr substringWithRange:range1];
                                [self.Get7dayArr addObject:str1];
                            }
                        }
                    }
                }
            }
            else if (buffer_[2] == 0x21)
            {
                if (buffer_[3] == 0xff)
                {
                    if ([theDelegate respondsToSelector:@selector(SDKGetHisHRUTCArr:)])
                    {
                        [theDelegate SDKGetHisHRUTCArr:self.GetUTCHRArr];
                    }
                    self.GetUTCHRArr = [[NSMutableArray alloc]init];
//                    JionHRCount = 0;
                }
                else
                {
                    //心率历史数据清单
                    NSString *Hex16Str = [self convertDataToHexStr:data];
                    
                    NSString *DataLen = [Hex16Str substringWithRange:NSMakeRange(2, 2)];
                    NSString *DataLenS = [NSString stringWithFormat:@"%lu",strtoul(DataLen.UTF8String, 0, 16)];//十六进制转普通字符;
                    
                    if (Hex16Str.length >= 6 + [DataLenS intValue]*2 - 8)
                    {
                        NSString *StrLen = [Hex16Str substringWithRange:NSMakeRange(6, [DataLenS intValue]*2 - 8)];
                        
                        // NSMutableArray *arrA = [[NSMutableArray alloc]init];
                        for (int i = 0; i < StrLen.length; i+=8)
                        {
                            NSRange range1 = NSMakeRange(i, 8);
                            NSString *str1 = [StrLen substringWithRange:range1];
                            
                            if (self.GetUTCHRArr.count == 0)
                            {
                                [self.GetUTCHRArr addObject:str1];
                            }
                            else
                            {
                                if (![self.GetUTCHRArr containsObject:str1])
                                {
                                    [self.GetUTCHRArr addObject:str1];
                                }
                            }
                        }
                    }
                }
            }
            else if (buffer_[2] == 0x22)
            {
                ComeHRCount++;
                
                //心率历史数据
                NSString *Hex16Str = [self convertDataToHexStr:data];
                NSString *DataLen = [Hex16Str substringWithRange:NSMakeRange(2, 2)];
                NSString *DataLenS = [NSString stringWithFormat:@"%lu",strtoul(DataLen.UTF8String, 0, 16)];//数据包长度
                
                if (ComeHRCount == 1)
                {
                    if (Hex16Str.length >= 14)
                    {
                        NSString *UTCStr = [Hex16Str substringWithRange:NSMakeRange(6, 8)];//UTC时间
                        HisHRUTCStr = [NSString stringWithFormat:@"%lu",strtoul(UTCStr.UTF8String, 0, 16)];//UTC时间
                    }
                }
                else
                {
                    NSString *UTCStr = [Hex16Str substringWithRange:NSMakeRange(6, 8)];//UTC时间
                    NSString *NumStr = [NSString stringWithFormat:@"%lu",strtoul(UTCStr.UTF8String, 0, 16)];//UTC时间
                    
                    if (ComeHRCount == [NumStr intValue])
                    {
                        
                    }
                    else
                    {
                        NSLog(@"出现了丢包的情况:%d",[NumStr intValue]);
                    }
                }
                
                if (Hex16Str.length >= 14+[DataLenS intValue]*2 - 16)
                {
                    NSString *HeartParamStr = [Hex16Str substringWithRange:NSMakeRange(14, [DataLenS intValue]*2 - 16)];
                    
                    @autoreleasepool {
                        [self.HisHRArr addObject:HeartParamStr];
                    }
                }
            }
            else if (buffer_[2] == 0x23)
            {
                NSLog(@"self.HisHRArr:%ld",self.HisHRArr.count);
                NSString *str = @"1";
                NSDictionary *dict1 = [[NSDictionary alloc]initWithObjectsAndKeys:str,@"OverGetParaStr", nil];
                NSNotification *notification1 =[NSNotification notificationWithName:@"OverGetParaStrNofication" object:nil userInfo:dict1];
                [[NSNotificationCenter defaultCenter] postNotification:notification1];
                
                
                //心率历史数据结束包
                NSMutableArray *HeartHisArray = [[NSMutableArray alloc]init];
                NSMutableArray *HeartUTCArray = [[NSMutableArray alloc]init];
                
                NSString *HeartParamStr  = nil;
                @autoreleasepool {
                    HeartParamStr = [self.HisHRArr componentsJoinedByString:@""];
                }
                
                for (int i = 0; i < HeartParamStr.length; i+=2)
                {
                    @autoreleasepool {
                        NSRange range1 = NSMakeRange(i, 2);
                        NSString *str1 = [HeartParamStr substringWithRange:range1];
                        
                        [HeartHisArray addObject:str1];
                    }
                }
                
                for (int j = 0; j < HeartHisArray.count; j++)
                {
                    @autoreleasepool {
                        int aw = [HisHRUTCStr intValue] + j;
                        
                        [HeartUTCArray addObject:[NSString stringWithFormat:@"%d",aw]];
                    }
                }
                
                NSMutableArray *HeartHisArrayS = [[NSMutableArray alloc]init];
                NSMutableArray *HeartUTCArrayS = [[NSMutableArray alloc]init];
                
                for (int i = 0; i < HeartHisArray.count; i++)
                {
                    @autoreleasepool {
                        NSString *HexStr = HeartHisArray[i];
                        NSString *Para1Str = [NSString stringWithFormat:@"%lu",strtoul(HexStr.UTF8String, 0, 16)];
                        
                        [HeartHisArrayS addObject:Para1Str];
                    }
                }
                
                for (NSString *TimeStr in HeartUTCArray)
                {
                    @autoreleasepool {
                        NSString *TextUTC = [self transformTime:[TimeStr intValue]];
                        [HeartUTCArrayS addObject:TextUTC];
                    }
                }
                
                if ([theDelegate respondsToSelector:@selector(SDKGetHisHRParaArr:andHisHRArr:)])
                {
                    [theDelegate SDKGetHisHRParaArr:HeartUTCArrayS andHisHRArr:HeartHisArrayS];
                }
                
                ComeHRCount = 0;
                self.HisHRArr = [[NSMutableArray alloc]init];
            }  else if (buffer_[2] == 0x37) {
                
                if (buffer_[3] == 0x00) {
                    NSLog(@"退出血氧模式");
                } else {
                    NSLog(@"进入血氧模式");
                    
                    int oxygen = buffer_[4];
                    BOOL posture = buffer_[5] == 1 ? true : false;
                    int pi = buffer_[6];
                    int onwrist = buffer_[7] == 1 ? true : false;
                    
                    if ([theDelegate respondsToSelector:@selector(SDKGetBloodOxygen:wristPosture:redPI:onWrist:)])
                    {
                        [theDelegate SDKGetBloodOxygen:oxygen wristPosture:posture redPI:pi onWrist:onwrist];
                    }
                    
                }
                
            } else if (buffer_[2] == 0x38) {
                
                //（单位：10℃）温度数据数值扩大了10倍
                int environmentTemp = [self bytes2ToInt:buffer_[3] byte2:buffer_[4]];
                int wristTemp = [self bytes2ToInt:buffer_[5] byte2:buffer_[6]];
                int bodyTemp = [self bytes2ToInt:buffer_[7] byte2:buffer_[8]];
                                
                if ([theDelegate respondsToSelector:@selector(SDKGetRealTimeTemp:wrist:body:)])
                {
                    [theDelegate SDKGetRealTimeTemp:environmentTemp/10.0 wrist:wristTemp/10.0 body:bodyTemp/10.0];
                }
                
            }
//            else if (buffer_[2] == 0x3f)
//            {
//                NSString *Hex16Str = [self convertDataToHexStr:data];
//                NSString *DataLen = [Hex16Str substringWithRange:NSMakeRange(6, 2)];
//                NSString *DataLenS = [NSString stringWithFormat:@"%lu",strtoul(DataLen.UTF8String, 0, 16)];//数据包长度
//                
//                if ([theDelegate respondsToSelector:@selector(SDKGetBLEStauts:)])
//                {
//                    [theDelegate SDKGetBLEStauts:DataLenS];
//                }
//            }
            else if (buffer_[2] == 0x40)
            {
                FiveMinCount++;
                NSLog(@"-----进来的次数-----:%d",FiveMinCount);
                
                if ([theDelegate respondsToSelector:@selector(SDKBagCountStr:)])
                {
                    [theDelegate SDKBagCountStr:[NSString stringWithFormat:@"%d",FiveMinCount]];
                }
                
                NSString *Hex16Str = [self convertDataToHexStr:data];
                NSString *StrLen = [Hex16Str substringWithRange:NSMakeRange(2, 2)];
                NSString *StrLenS = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                
                NSString *DataStr = [Hex16Str substringWithRange:NSMakeRange(6, [StrLenS intValue] * 2 - 8)];
                
                for (int i = 0; i < DataStr.length; i+=16)
                {
                    NSRange range1 = NSMakeRange(i, 16);
                    NSString *str1 = [DataStr substringWithRange:range1];
                    [self.GetTimStepArr addObject:str1];
                }
            }
            else if (buffer_[2] == 0x41)
            {
                NSMutableArray *HISUTCStepArr = [[NSMutableArray alloc]init];
                
                for (NSString *DataStr in self.GetTimStepArr)
                {
                    NSMutableArray *HisArrSS = [[NSMutableArray alloc]init];
                    
                    //UTC
                    NSString *StrLen = [DataStr substringWithRange:NSMakeRange(0, 8)];
                    NSString *UTCStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                    NSString *UTCStr1 = [self transformTime1:[UTCStr intValue]];
                    [HisArrSS addObject:UTCStr1];
                    
                    //Steps
                    NSString *StrLen1 = [DataStr substringWithRange:NSMakeRange(8, 8)];
                    NSString *StepStr = [NSString stringWithFormat:@"%lu",strtoul(StrLen1.UTF8String, 0, 16)];
                    [HisArrSS addObject:StepStr];
                    
                    [HISUTCStepArr addObject:HisArrSS];
                }
                
                if ([theDelegate respondsToSelector:@selector(SDKGetIntertTimeArr:)])
                {
                    [theDelegate SDKGetIntertTimeArr:HISUTCStepArr];
                }
                self.GetTimStepArr = [[NSMutableArray alloc]init];
                
            }
            else if (buffer_[2] == 0x42)
            {
               // OnceMinCount++;
              //  NSLog(@"-----进来的次数1-----:%d",OnceMinCount);
    
                NSString *Hex16Str = [self convertDataToHexStr:data];
                NSString *StrLen = [Hex16Str substringWithRange:NSMakeRange(2, 2)];
                NSString *StrLenS = [NSString stringWithFormat:@"%lu",strtoul(StrLen.UTF8String, 0, 16)];
                
                NSString *DataStr = [Hex16Str substringWithRange:NSMakeRange(6, [StrLenS intValue] * 2 - 8)];
                
                for (int i = 0; i < DataStr.length; i+=8)
                {
                    NSRange range1 = NSMakeRange(i, 8);
                    NSString *str1 = [DataStr substringWithRange:range1];
                    [self.GetSingleTimArr addObject:str1];
                    
                    if ([theDelegate respondsToSelector:@selector(SDKBag1CountStr:)])
                    {
                        [theDelegate SDKBag1CountStr:[NSString stringWithFormat:@"%ld",self.GetSingleTimArr.count]];
                    }
                }
            }
            else if (buffer_[2] == 0x43)
            {
                NSMutableArray *HISUTCSingleArr = [[NSMutableArray alloc]init];
                
                for (NSString *DataStr in self.GetSingleTimArr)
                {
                    NSString *UTCStr = [NSString stringWithFormat:@"%lu",strtoul(DataStr.UTF8String, 0, 16)];
                    NSString *UTCStr1 = [self transformTime1:[UTCStr intValue]];
                    [HISUTCSingleArr addObject:UTCStr1];
                }
                
                if ([theDelegate respondsToSelector:@selector(SDKGetSingleUTCArr:)])
                {
                    [theDelegate SDKGetSingleUTCArr:HISUTCSingleArr];
                }
                self.GetSingleTimArr = [[NSMutableArray alloc]init];
            }
        }
    }
}


- (void)enterOxygenMode {
    NSString *StrLen = @"ff053701";
    [self BLEReadData:StrLen];
}

- (void)quitOxygenMode {
    NSString *StrLen = @"ff053700";
    [self BLEReadData:StrLen];
}

- (void)requestRealTimeTemperature {
    NSString *StrLen = @"ff0438";
    [self BLEReadData:StrLen];
}



#pragma mark - APP写入参数命令
- (void)BLEReadData:(NSString *)dataStr
{
    [self CheckSun:dataStr];
    [self CheckSun28:dataStr andCheckStr:self.FitChenSunStr];
}

- (void)CheckSun28:(NSString *)DateLenStr andCheckStr:(NSString *)CheckStr
{
    unsigned long num1 = strtoul([CheckStr UTF8String], 0, 16);
    uint8_t sss = 0x00 - num1;
    
    uint8_t SSS = sss ^ 0x3a;//异或0x3a

    NSString *DataStrA = [DateLenStr stringByAppendingString:[NSString stringWithFormat:@"%02x",SSS]];
    const char *ChataStr = [DataStrA UTF8String];
    
    //延迟发送
    usleep(170 * 1000);
    [self BLESendYinDaBuff:ChataStr];
}

- (void)BLESendYinDaBuff:(const char *)Buff
{
    NSMutableData *data = [NSMutableData data];
    if (Buff)
    {
        uint32_t len = (uint32_t)strlen(Buff);
        
        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit(Buff[i]) && (isxdigit(Buff[i+1])) )
            {
                singleNumberString[0] = Buff[i];
                singleNumberString[1] = Buff[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp) length:1];
            }
            else
            {
                break;
            }
        }
        NSLog(@"App Send Data:%@",data);
        FiveMinCount = 0;
        OnceMinCount = 0;
        if (self.peripheral != nil)
        {
            [self.peripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

- (void)CheckSun:(NSString *)CountString
{
    NSMutableArray *originalArr = [self getArrWithString:CountString];
    uint8_t checksum = 0x00;
    
    
    for (NSInteger i = 0; i < originalArr.count; i++) {
        NSString *str = [NSString stringWithFormat:@"0x%@",originalArr[i]];
        const char *temChar = [str UTF8String];
        int temW;
        sscanf(temChar, "0x%2x",&temW);
        checksum += temW;
    }
    // NSLog(@"%x", checksum);
    
    self.FitChenSunStr = [NSString stringWithFormat:@"%02x",checksum];
}
- (NSMutableArray *)getArrWithString:(NSString *)keysource {
    NSMutableArray *keysourceArr = [NSMutableArray array];
    for (NSInteger i = 0; i < keysource.length/2; i++) {
        NSString *str = [keysource substringWithRange:NSMakeRange(2*i, 2)];
        str = [NSString stringWithFormat:@"%@",str];
        [keysourceArr addObject:str];
    }
    return keysourceArr;
}

- (void)tongxinMa28
{
    int i = (int)(random()%255)+1;
    NSString *str1 = [self ToHex:i];
    unsigned long num1 = strtoul([str1 UTF8String], 0, 16);
    uint8_t cc = num1;
    
    //Byte cc = 0x37;
    uint8_t a = cc^0xd5;
    
    NSString *yihouStr = [self ToHex:a];
    
    uint8_t b1 = 0x43^cc;
    uint8_t b2 = 0x68^cc;
    uint8_t b3 = 0x69^cc;
    uint8_t b4 = 0x6c^cc;
    uint8_t b5 = 0x65^cc;
    uint8_t b6 = 0x61^cc;
    uint8_t b7 = 0x66^cc;
    uint8_t b8 = 0x5f^cc;
    uint8_t b9 = 0x32^cc;
    uint8_t b10 = 0x30^cc;
    uint8_t b11 = 0x31^cc;
    uint8_t b12 = 0x39^cc;
    uint8_t b13 = 0x31^cc;
    uint8_t b14 = 0x31^cc;
    
    NSString *ChileafStr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14];
    
    NSString *strLen = @"ff2813";
    
    NSString *DatalenStr = [strLen stringByAppendingString:ChileafStr];
    NSString *DatalenStr1 = [DatalenStr stringByAppendingString:yihouStr];

    [self BLEReadData:DatalenStr1];
}

-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

- (NSString *)dateTransformToTimeSp
{
    NSDate *date = [NSDate date];
   // NSTimeInterval timeIn = [date timeIntervalSince1970];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate *localDate = [date  dateByAddingTimeInterval:interval];
    NSTimeInterval timeIn2 = [localDate timeIntervalSince1970];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f",timeIn2];
    
    return timeSp;
}

- (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

- (NSString *)transformTime1:(long long)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *template = @"yyyy-MM-dd HH:mm:ss";
    NSString *formatStr = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatStr];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *time = [formatter stringFromDate:date];
    return time;
}

#pragma mark - UTC转本地时间
- (NSString *)transformTime:(long long)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *template = @"HH:mm:ss";
    NSString *formatStr = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:formatStr];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *time = [formatter stringFromDate:date];
    return time;
}

#pragma mark - 16进制转ASSCI
- (NSString *)HEXToASSCI:(NSData *)data
{
    NSString *Hex16Str = [self convertDataToHexStr:data];
    
    //NSLog(@"Hex16Str:%@",Hex16Str);
    
    NSMutableArray *WifArr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < Hex16Str.length; i+=2)
    {
        NSRange range1 = NSMakeRange(i, 2);
        NSString *str1 = [Hex16Str substringWithRange:range1];
        
        [WifArr addObject:str1];
    }
   // NSLog(@"WifArr:%@",WifArr);
    
    NSMutableArray *arra = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < WifArr.count; i++)
    {
        NSString *strAA = WifArr[i];
        NSString *Para1Str = [NSString stringWithFormat:@"%lu",strtoul(strAA.UTF8String, 0, 16)];
        char st = [Para1Str intValue];
        NSString *IpStr = [NSString stringWithFormat:@"%c",st];
        
        [arra addObject:IpStr];
    }
   // NSLog(@"arra:%@",arra);
    
    if (arra.count != 0)
    {
        NSString *string = [arra componentsJoinedByString:@"/"];
        NSString *str = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
        
        return str;
    }
    
    return 0;
}

- (int)bytes4ToInt:(uint8_t *)bytes {
    int addr = bytes[0] & 0xFF;
    addr |= ((bytes[1] << 8) & 0xFF00);
    addr |= ((bytes[2] << 16) & 0xFF0000);
    addr |= ((bytes[3] << 24) & 0xFF000000);
    return addr;
}

- (int)bytes2ToInt:(uint8_t *)bytes {
    int addr = bytes[0] & 0xFF;
    addr |= ((bytes[1] << 8) & 0xFF00);
    return addr;
}

- (int)bytes2ToInt:(uint8_t)byte1 byte2:(uint8_t)byte2 {
    
    int addr = byte1 * 256 + byte2;
    
    return addr;
}


@end
