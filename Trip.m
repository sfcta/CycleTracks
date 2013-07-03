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
//  Trip.m
//  CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/22/09.
//	For more information on the project,
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>
//

//
//  Trip.m
//
//  Created by Gregory Kip on 6/21/13.
//  Adapted to OpenBike by Gregory Kip (gkip@permusoft.com) and others.
//

#import "Trip.h"
#import "Coord.h"
#import "User.h"


@implementation Trip

@dynamic start;
@dynamic distance;
@dynamic notes;
@dynamic uploaded;
@dynamic purpose;
@dynamic duration;
@dynamic saved;
@dynamic ease;
@dynamic safety;
@dynamic convenience;
@dynamic coords;
@dynamic user;

@end
