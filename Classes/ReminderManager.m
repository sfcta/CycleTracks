/**  CycleTracks, Copyright 2009-2013 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  ReminderManager.m
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/30/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>
//

//
// Adapted to Open Bike by Gregory Kip (gkip@permusoft.com) and others.
//


#include <AudioToolbox/AudioToolbox.h>
#import "constants.h"
#import "ReminderManager.h"
#import "TripManager.h"

#define k2Minutes     (120.0)
#define k10Minutes	 (600.0)
#define k15Minutes	 (900.0)
#define kNumReminders (10)

//#define kEnableTestReminder  (YES)
#define kEnableTestReminder  (NO)

@implementation ReminderManager
@synthesize reminders;

- (id)init {
	if ((self = [super init]) != nil) {
      NSTimeInterval first_seconds;
      NSTimeInterval seconds;
      
      if (kEnableTestReminder) {
         first_seconds = k2Minutes;
         seconds = k2Minutes;
      } else {
         first_seconds = k15Minutes;
         seconds = k10Minutes;
      }
      
      NSLog(@"Reminder initWithFirstFireInterval: %f interval: %f", first_seconds, seconds);
      
		//NSLog(@"ReminderManager init");
		reminders = [[NSMutableArray arrayWithCapacity:kNumReminders*2] retain];
		
		// add reminders here
      
      // schedule all of our reminders to fire
      for (int reminder_num=0; reminder_num < kNumReminders; reminder_num++) {
         NSTimeInterval reminder_secs = (reminder_num==0 ? first_seconds : first_seconds+reminder_num*seconds);
         
         // Local notification will go if it's in the background
         UILocalNotification *localNotif = [[UILocalNotification alloc] init];
         localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:reminder_secs];
         localNotif.timeZone = [NSTimeZone defaultTimeZone];
         localNotif.alertBody = [NSString stringWithFormat:@"Open Bike has been recording for %d minutes", ((int)(reminder_secs))/60];
         localNotif.soundName = @"bicycle-bell-normalized.aiff";
         
         [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
         [localNotif release];
         
         // Timer will trigger if it's in the foreground
         [reminders addObject:[NSTimer scheduledTimerWithTimeInterval:reminder_secs
                                                               target:self
                                                             selector:@selector(remindBell:)
                                                             userInfo:nil
                                                              repeats:NO]];
      }
      
	}
	
	return self;
}

- (void)dealloc {
    [reminders release];
    [super dealloc];
}

//- (void)addRemindersWithFirstFireInterval:(NSTimeInterval)first_seconds
//                                 interval:(NSTimeInterval)seconds
//{
//	if ( self = [super init] )
//	{
//        // schedule all of our reminders to fire
//        for (int reminder_num=0; reminder_num < kNumReminders; reminder_num++) {
//            NSTimeInterval reminder_secs = (reminder_num==0 ? first_seconds :
//                                            first_seconds+reminder_num*seconds);
//            
//            // Local notification will go if it's in the background
//            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//            localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:reminder_secs];
//            localNotif.timeZone = [NSTimeZone defaultTimeZone];
//            localNotif.alertBody = [NSString
//                                    stringWithFormat:@"Open Bike has been recording for %d minutes",
//                                    (int)(reminder_secs)/60];
//            localNotif.soundName = @"bicycle-bell-normalized.aiff"; // 
//            
//            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//            [localNotif release];
//            
//            // Timer will trigger if it's in the foreground
//            [reminders addObject:[NSTimer scheduledTimerWithTimeInterval:reminder_secs
//                                                                  target:self
//                                                                selector:@selector(remindBell:)
//                                                                userInfo:nil
//                                                                 repeats:NO]];
//        }
//    }
//}

- (void)remindBell:(NSTimer*)theTimer
{
    CFURLRef		soundFileURLRef;
    SystemSoundID	soundFileObject;
    
    // Get the main bundle for the app
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    
    // Get the URL to the sound file to play
    soundFileURLRef = CFBundleCopyResourceURL( mainBundle, CFSTR ("bicycle-bell-normalized"), CFSTR ("aiff"), NULL );
    
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID( soundFileURLRef, &soundFileObject );

    // play audio + vibrate
    AudioServicesPlayAlertSound( soundFileObject );
}

- (void)disableReminders
{
	NSLog(@"disableReminders");
    // remove local notifs
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // disable all timers
    for (NSTimer* reminder in reminders) {
        [reminder invalidate];
    }
    [reminders removeAllObjects];
}


@end
