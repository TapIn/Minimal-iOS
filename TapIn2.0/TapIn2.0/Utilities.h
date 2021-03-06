//
//  Location.h
//  Livu
//
//  Created by Vu Tran on 5/28/12.
//  Copyright (c) 2012 Steve McFarlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol NetworkUtilitiesDelegate
@optional
-(void)didCompleteHandshake:(NSDictionary *)response;
-(void)handshakeDidFailWithErrors:(NSString*)error;
-(void) responseDidSucceed:(NSDictionary*)data; 
@end

@interface Utilities : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager * locationManager;
    CLLocation *location;
    NSString * uid;
    NSString * streamID;
    BOOL streaming;
}
+(id)sharedInstance;
+(void) setUserDefaultValue:(id)value forKey:(NSString *)key;
+(id) userDefaultValueforKey:(NSString *)key;
+(NSString*) phoneID;
-(void)sendPost:(NSString*)host params:(NSMutableDictionary*)params;
-(void)sendGet:(NSString*)host params:(NSMutableDictionary*)params delegate:(NSObject*)_delegate;
-(void)startStream:(NSObject*)_delegate;
-(void)signout;
+(NSDictionary*)livuSettings;
-(NSString*)generateUuidString;
+(int) timestamp;
@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSString *streamID;
@property (nonatomic) BOOL streaming;
@property (nonatomic, retain) id <NetworkUtilitiesDelegate> delegate;
@end
