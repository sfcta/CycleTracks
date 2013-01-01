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
//  CJSONDeserializer.h
//  TouchJSON
//
//  Created by Jonathan Wight on 12/15/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kJSONDeserializerErrorDomain /* = @"CJSONDeserializerErrorDomain" */;

@protocol CDeserializerProtocol <NSObject>

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;

@end

#pragma mark -

@interface CJSONDeserializer : NSObject <CDeserializerProtocol> {

}

+ (id)deserializer;

- (id)deserializeAsDictionary:(NSData *)inData error:(NSError **)outError;

@end

#pragma mark -

@interface CJSONDeserializer (CJSONDeserializer_Deprecated)

/// You should switch to using deserializeAsDictionary:error: instead.
- (id)deserialize:(NSData *)inData error:(NSError **)outError;

@end
