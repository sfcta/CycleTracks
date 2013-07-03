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
//  CDataScanner.m
//  TouchJSON
//
//  Created by Jonathan Wight on 04/16/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//

#import "CDataScanner.h"

#import "CDataScanner_Extensions.h"

@interface CDataScanner ()
@property (readwrite, nonatomic, strong) NSCharacterSet *doubleCharacters;
@end

#pragma mark -

inline static unichar CharacterAtPointer(void *start, void *end)
{
#pragma unused(end)

const u_int8_t theByte = *(u_int8_t *)start;
if (theByte & 0x80)
	{
	// TODO -- UNICODE!!!! (well in theory nothing todo here)
	}
const unichar theCharacter = theByte;
return(theCharacter);
}

@implementation CDataScanner

@dynamic data;
@dynamic scanLocation;
@dynamic isAtEnd;
@synthesize doubleCharacters;

+ (id)scannerWithData:(NSData *)inData
{
CDataScanner *theScanner = [[self alloc] init];
theScanner.data = inData;
return(theScanner);
}

- (id)init
{
if ((self = [super init]) != nil)
	{
	self.doubleCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789eE-."];
	}
return(self);
}

- (void)dealloc
{
self.data = NULL;
//
}

- (NSUInteger)scanLocation
{
return(current - start);
}

- (NSData *)data
{
return(data); 
}

- (void)setData:(NSData *)inData
{
if (data != inData)
	{
	if (data)
		{
		data = NULL;
		}
	
	if (inData)
		{
		data = inData;
		//
		start = (u_int8_t *)data.bytes;
		end = start + data.length;
		current = start;
		length = data.length;
		}
    }
}

- (void)setScanLocation:(NSUInteger)inScanLocation
{
current = start + inScanLocation;
}

- (BOOL)isAtEnd
{
return(self.scanLocation >= length);
}

- (unichar)currentCharacter
{
return(CharacterAtPointer(current, end));
}

#pragma mark -

- (unichar)scanCharacter
{
const unichar theCharacter = CharacterAtPointer(current++, end);
return(theCharacter);
}

- (BOOL)scanCharacter:(unichar)inCharacter
{
unichar theCharacter = CharacterAtPointer(current, end);
if (theCharacter == inCharacter)
	{
	++current;
	return(YES);
	}
else
	return(NO);
}

- (BOOL)scanUTF8String:(const char *)inString intoString:(NSString **)outValue;
{
const size_t theLength = strlen(inString);
if ((size_t)(end - current) < theLength)
	return(NO);
if (strncmp((char *)current, inString, theLength) == 0)
	{
	current += theLength;
	if (outValue)
		*outValue = [NSString stringWithUTF8String:inString];
	return(YES);
	}
return(NO);
}

- (BOOL)scanString:(NSString *)inString intoString:(NSString **)outValue
{
if ((size_t)(end - current) < inString.length)
	return(NO);
if (strncmp((char *)current, [inString UTF8String], inString.length) == 0)
	{
	current += inString.length;
	if (outValue)
		*outValue = inString;
	return(YES);
	}
return(NO);
}

- (BOOL)scanCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue
{
u_int8_t *P;
for (P = current; P < end && [inSet characterIsMember:*P] == YES; ++P)
	;

if (P == current)
	{
	return(NO);
	}

if (outValue)
	{
	*outValue = [[NSString alloc] initWithBytes:current length:P - current encoding:NSUTF8StringEncoding];
	}
	
current = P;

return(YES);
}

- (BOOL)scanUpToString:(NSString *)inString intoString:(NSString **)outValue
{
const char *theToken = [inString UTF8String];
const char *theResult = strnstr((char *)current, theToken, end - current);
if (theResult == NULL)
	{
	return(NO);
	}

if (outValue)
	{
	*outValue = [[NSString alloc] initWithBytes:current length:theResult - (char *)current encoding:NSUTF8StringEncoding];
	}

current = (u_int8_t *)theResult;

return(YES);
}

- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)inSet intoString:(NSString **)outValue
{
u_int8_t *P;
for (P = current; P < end && [inSet characterIsMember:*P] == NO; ++P)
	;

if (P == current)
	{
	return(NO);
	}

if (outValue)
	{
	*outValue = [[NSString alloc] initWithBytes:current length:P - current encoding:NSUTF8StringEncoding];
	}
	
current = P;

return(YES);
}

- (BOOL)scanNumber:(NSNumber **)outValue
{
// Replace all of this with a strtod call
NSString *theString = NULL;
if ([self scanCharactersFromSet:doubleCharacters intoString:&theString])
	{
	if (outValue)
		*outValue = [NSNumber numberWithDouble:[theString doubleValue]]; // TODO dont use doubleValue
	return(YES);
	}
return(NO);
}

- (void)skipWhitespace
{
u_int8_t *P;
for (P = current; P < end && (isspace(*P)); ++P)
	;

current = P;
}

- (NSString *)remainingString
{
NSData *theRemainingData = [NSData dataWithBytes:current length:end - current];
NSString *theString = [[NSString alloc] initWithData:theRemainingData encoding:NSUTF8StringEncoding];
return(theString);
}

@end
