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

#import "RadarForwarderAppDelegate.h"
#import "RadarForwarderConstants.h"
#import "RadarUrlParser.h"

@interface RadarForwarderAppDelegate ()

- (void) registerForUrls;
- (void)restartIdleTimer;
- (void)timerFired:(NSTimer *)timer;

@end

@implementation RadarForwarderAppDelegate

+ (void)initialize
{
    NSMutableDictionary * defaultPrefs = [NSMutableDictionary dictionary];
    [defaultPrefs setObject:@"http://openradar.appspot.com/rdar?number=%@"
                     forKey:kForwardingUrlFormatKey];

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:defaultPrefs];
}

- (void)restartIdleTimer
{
    if (_idleTimer != nil)
    {
        [_idleTimer invalidate];
        [_idleTimer release];
        _idleTimer = nil;
    }
    
    _idleTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:NO];
    [_idleTimer retain];
}

- (void)timerFired:(NSTimer *)timer
{
    [NSApp terminate:self];
}

- (void) registerForUrls;
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(getUrl:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
}

- (void) getUrl: (NSAppleEventDescriptor *) event
 withReplyEvent: (NSAppleEventDescriptor *) replyEvent;
{
    [self restartIdleTimer];

    NSString * urlString = [[event paramDescriptorForKeyword:keyDirectObject]
                            stringValue];

    NSString * number = parseRadarUrl(urlString);
    if (number == nil)
    {
        NSLog(@"Malformed rdar URL: %@", urlString);
        return;
    }

    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * forwardingUrlFormat = [defaults objectForKey:kForwardingUrlFormatKey];

    NSString * newUrlString = [NSString stringWithFormat:forwardingUrlFormat, number];
    NSURL * newUrl = [NSURL URLWithString:newUrlString];
    [[NSWorkspace sharedWorkspace] openURL:newUrl];
}

- (void)awakeFromNib
{
    [self registerForUrls];
    [self restartIdleTimer];
}

@end
