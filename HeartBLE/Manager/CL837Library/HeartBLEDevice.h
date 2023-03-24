//
//  HeartBLEDevice.h
//  HeartTestDemo
//
//  Created by 郭志奇 on 2019/8/7.
//  Copyright © 2019 郭志奇. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@class HeartBLEDevice;

@protocol BLEDeviceDelegate <NSObject>

//Get device information
- (void)SDKgetInfo:(NSData *)info withDevice:(HeartBLEDevice *)Device;

- (void)SDKFitRunSParamter:(int)RunPara andFitKM:(float)FitKM andFitCalor:(float)FitCalor;

- (void)SDKFitHeartParamter:(NSString *_Nonnull)HeartStr RRIs:(NSArray *_Nonnull)RRIs;

- (void)SDKDianciStr:(NSString *_Nullable)DianStr;

- (void)SDKReadRSSI:(NSString *_Nullable)RSSIStr;

- (void)SDKDeviceBanBen:(NSString *_Nullable)BenStr;

- (void)SDKRealData:(NSData *_Nullable)data;

- (void)SDKGet7DaysHisParam:(NSMutableArray *_Nullable)ParamArr;

- (void)SDKGetHisHRUTCArr:(NSMutableArray *_Nullable)UTCArr;

- (void)SDKGetHisHRParaArr:(NSMutableArray *_Nullable)UTCArr andHisHRArr:(NSMutableArray *_Nullable)HRArr;

- (void)SDKGetIntertTimeArr:(NSMutableArray *_Nullable)ParaArr;

- (void)SDKGetSingleUTCArr:(NSMutableArray *_Nullable)UTCArr;

- (void)SDKGetUserInfoState:(NSString *_Nullable)StateStr;

- (void)SDKUserInfo:(NSString *_Nullable)OLdStr andSex:(NSString *_Nullable)SexStr andWeight:(NSString *_Nullable)WeightStr andHeight:(NSString *_Nullable)HeightStr andPhoneNum:(NSString *_Nullable)PhNumStr;

- (void)SDKBagCountStr:(NSString *_Nullable)CountStr;
- (void)SDKBag1CountStr:(NSString *_Nullable)CountStr;

/// 获取实时温度数据
/// @param ambient 环境温度
/// @param wrist 手腕温度
/// @param body 体温
- (void)SDKGetRealTimeTemp:(float)ambient wrist:(float)wrist body:(float)body;


/// 获取血氧值
/// @param BloodOxygen 血氧值
/// @param posture 手腕姿势是否正确，YES 正确，NO 错误
/// @param PI 红光PI值  0：未检测到脉搏，<8信号较弱，>15信号良好
/// @param onWrist 是否脱腕
- (void)SDKGetBloodOxygen:(int)BloodOxygen wristPosture:(BOOL)posture redPI:(int)PI onWrist:(BOOL)onWrist;

@end

@interface HeartBLEDevice : NSObject

//connection
- (void)connect;

//disconnect
- (void)disconncet;

//Set the agent
- (void)setDelegate:(id)delegate;

//Data is written to
- (void)BLEReadData:(NSString *)dataStr;

/// 进入血氧模式
- (void)enterOxygenMode;
/// 退出血氧模式
- (void)quitOxygenMode;
/// 请求实时温度
- (void)requestRealTimeTemperature;

// Device name
@property (nonatomic,copy) NSString *DeviceName;

//UUID
@property (nonatomic,copy) NSString *UUIDStr;

//Equipment signal strength
@property (nonatomic,copy) NSString *RSSI;

//Initialization service
- (instancetype)initWithPeriphral:(id)thePeripheal;

@end

NS_ASSUME_NONNULL_END
