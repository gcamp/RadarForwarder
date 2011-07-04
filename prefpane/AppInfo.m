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

#import "AppInfo.h"


@implementation AppInfo

@synthesize bundleId = _bundleId;
@synthesize name = _name;
@synthesize icon = _icon;

+ (id)appInfoWithBundleId:(NSString *)bundleId;
{
    id o = [[self alloc] initWithBundleId:bundleId];
    return [o autorelease];
}

- (id)initWithBundleId:(NSString *)bundleId;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _bundleId = [bundleId copy];

    NSWorkspace * workspace = [NSWorkspace sharedWorkspace];
    NSString * path = [workspace absolutePathForAppBundleWithIdentifier:_bundleId];
    NSBundle * bundle = [NSBundle bundleWithPath:path];
    NSString * name = [[bundle localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    _name = [name retain];
    
    _icon = [[workspace iconForFile:path] retain];
    
    return self;
}

- (void)dealloc
{
    [_icon release];
    [_name release];
    [_bundleId release];
    
    [super dealloc];
}

@end
