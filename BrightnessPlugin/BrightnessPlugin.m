//
//  BrightnessPlugin.m
//  BrightnessPlugin
//
//  Created by Atsushi on 11/03/27.
//  Copyright 2011 Atsushi Tagami. All rights reserved.
//

#import "BrightnessPlugin.h"
#include <IOKit/graphics/IOGraphicsLib.h>

const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);

@implementation BrightnessPlugin

-(id) initWithWebView:(WebView*) webView
{
	self = [super init];
	_timer = nil;
	return self;
}

-(void) dealloc
{
	if(_timer != nil){ [_timer invalidate]; _timer = nil; };
	[super dealloc];
}

-(void) windowScriptObjectAvailable:(WebScriptObject*) webScriptObject
{
	[webScriptObject setValue:self forKey:@"BrightnessPlugin"];
}


+(BOOL) isSelectorExcludedFromWebScript:(SEL)selector
{
	if(selector == @selector(setBrightness:)){
		return NO;
	}
	return YES;
}


+(NSString*) webScriptNameForSelector:(SEL)selector
{
	
	if(selector == @selector(setBrightness:)){
		return @"setBrightness";
	}
	return nil;	
}

-(BOOL) setBrightness:(NSString*) value
{
	if(_timer != nil){ [_timer invalidate]; _timer = nil; };
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.05
											  target:self
											selector:@selector(downBrightness:)
											userInfo:value
											 repeats:NO];
	return YES;
}



-(void) downBrightness:(NSTimer*) timer 
{
	CGDirectDisplayID display[kMaxDisplays];
	CGDisplayCount numDisplays;
	
	NSString* value = (NSString*)[timer userInfo];
	float brightness = 0.0;
	if(value != nil){ brightness = [value floatValue]; };
	
	CGDisplayErr err = CGGetActiveDisplayList(kMaxDisplays, display, &numDisplays);
	if (err != CGDisplayNoErr){
		return;
	}
	
	BOOL repeatTimer = NO;
	for(CGDisplayCount i=0; i<numDisplays; i++){
		CGDirectDisplayID dis = display[i];
		CGDisplayModeRef originalMode = CGDisplayCopyDisplayMode(dis);
		if (originalMode == NULL) continue;
		io_service_t service = CGDisplayIOServicePort(dis);
		float currentBrightness;
		IODisplayGetFloatParameter(service, kNilOptions, kDisplayBrightness,
										 &currentBrightness);
		if(currentBrightness > brightness){
			float newBrightness = currentBrightness - 0.05;
			if (newBrightness < brightness) newBrightness = brightness;
			IODisplaySetFloatParameter(service, kNilOptions, kDisplayBrightness, newBrightness);
			if (newBrightness > brightness) repeatTimer = YES;
		}
        CGDisplayModeRelease(originalMode);
	}
	if(repeatTimer == YES){
		_timer = [NSTimer scheduledTimerWithTimeInterval:0.05
												  target:self
												selector:@selector(downBrightness:)
												userInfo:value
												 repeats:NO];
	}else{
		_timer = nil;
	}
	
}

@end
