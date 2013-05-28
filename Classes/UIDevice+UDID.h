//
//  UIDevice+UDID.h
//  CycleTracks
//
//  Created by Gregory Kip on 5/28/13.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (UDID)

-(NSString *)macAddress;
-(NSString *)uniqueDeviceIdentifier;

@end
