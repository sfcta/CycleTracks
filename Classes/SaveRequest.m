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
//  SaveRequest.m
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 8/25/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>
//

//
// Adapted to Open Bike by Gregory Kip (gkip@permusoft.com) and others.
//

#import "constants.h"
#import "CycleTracksAppDelegate.h"
#import "SaveRequest.h"


@implementation SaveRequest

@synthesize request, deviceUniqueIdHash, postVars;

#pragma mark init

- initWithPostVars:(NSDictionary *)inPostVars
{
	if (self = [super init])
	{
		// Nab the unique device id hash from our delegate.
		CycleTracksAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		self.deviceUniqueIdHash = delegate.uniqueIDHash;
		
		// create request.
		self.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSaveURL]]; // prop set retains
		// [request addValue:kServiceUserAgent forHTTPHeaderField:@"User-Agent"];

		// setup POST vars
		[request setHTTPMethod:@"POST"];
		self.postVars = [NSMutableDictionary dictionaryWithDictionary:inPostVars];
	
		// add hash of device id
		[postVars setObject:deviceUniqueIdHash forKey:@"device"];

		// convert dict to string
		NSMutableString *postBody = [NSMutableString string];

		for(NSString * key in postVars)
			[postBody appendString:[NSString stringWithFormat:@"%@=%@&", key, [postVars objectForKey:key]]];

		NSLog(@"initializing HTTP POST request to %@ with %d bytes", kSaveURL, [[postBody dataUsingEncoding:NSUTF8StringEncoding] length]);
      
		[request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	[postVars release];
	[request release];
	[deviceUniqueIdHash release];
}

#pragma mark instance methods

// add POST vars to request
- (NSURLConnection *)getConnectionWithDelegate:(id)delegate
{
	
	NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
	return [conn autorelease];
}

@end
