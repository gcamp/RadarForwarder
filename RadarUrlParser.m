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

#import "RadarUrlParser.h"


NSString * parseRadarUrl(NSString * urlPath)
{
    // We don't care what the scheme is.  We only register for schemes we want
    // to respond to, anyways.
    NSRegularExpression* expression = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-Z-]+://(?:problem/)?(\\d+)$" 
                                                                           options:(NSRegularExpressionCaseInsensitive) error:nil];
    NSTextCheckingResult* result = [expression firstMatchInString:urlPath options:0 range:NSMakeRange(0, urlPath.length)];
    
    if (result.range.location == NSNotFound) return nil;
    else {
        NSString* matchedString = [urlPath substringWithRange:result.range];
        return [matchedString stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    }
}
