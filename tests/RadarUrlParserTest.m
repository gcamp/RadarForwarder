/*
 * Copyright (c) 2008 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "RadarUrlParserTest.h"
#import "RadarUrlParser.h"


@implementation RadarUrlParserTest

- (void)testValidNumberOnly
{
    NSString * radar =  parseRadarUrl(@"rdar://12345");
    STAssertEqualObjects(@"12345", radar, nil);
}

- (void)testValidProblemAndNumber
{
    NSString * radar =  parseRadarUrl(@"rdar://problem/12345");
    STAssertEqualObjects(@"12345", radar, nil);
}

- (void)testOtherScheme
{
    NSString * radar =  parseRadarUrl(@"foo://problem/12345");
    STAssertEqualObjects(@"12345", radar, nil);
}

- (void)testInvalid
{
    STAssertNil(parseRadarUrl(@"foo rdar://12345"), nil);
    STAssertNil(parseRadarUrl(@"rdar://12345 foo"), nil);
    STAssertNil(parseRadarUrl(@" rdar://12345 "), nil);
    STAssertNil(parseRadarUrl(@"rdar ://12345 "), nil);
    STAssertNil(parseRadarUrl(@"rdar://"), nil);
    STAssertNil(parseRadarUrl(@"rdar://problem"), nil);
    STAssertNil(parseRadarUrl(@"rdar://problem/"), nil);
    STAssertNil(parseRadarUrl(@"rdar://12345/"), nil);
    STAssertNil(parseRadarUrl(@"rdar://problem/12345/"), nil);
    STAssertNil(parseRadarUrl(@"rdar://foo/12345"), nil);
    STAssertNil(parseRadarUrl(@"rdar://12345?foo=bar"), nil);
    STAssertNil(parseRadarUrl(@"rdar:/12345"), nil);
}

@end
