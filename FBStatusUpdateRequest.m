//
//  FBStatusUpdateRequest.m
//  Thumbprint
//
//  Created by Blake Watters on 5/13/09.
//  Copyright 2009 Objective 3. All rights reserved.
//

#import "FBStatusUpdateRequest.h"

@interface FBStatusUpdateRequest (Private)
- (void)informDelegateStatusUpdateWasSuccessful;
- (void)informDelegateStatusUpdateFailed;
@end

@implementation FBStatusUpdateRequest

@synthesize session = _session;
@synthesize delegate = _delegate;
@synthesize statusText = _statusText;

static NSString* kFacebookUpdateStatusPermissionName = @"status_update";
static NSString* kFacebookUpdateStatusApiCallName = @"facebook.Users.setStatus";

+ (FBStatusUpdateRequest*)requestStatusUpdate:(NSString*)statusString withSession:(FBSession*)session delegate:(id<FBStatusUpdateRequestDelegate>)delegate {
	FBStatusUpdateRequest* statusUpdateRequest = [[[FBStatusUpdateRequest alloc] initWithSession:session] autorelease];
	statusUpdateRequest.delegate = delegate;
	[statusUpdateRequest updateStatus:statusString];
	
	return statusUpdateRequest;
}

+ (FBStatusUpdateRequest*)requestStatusUpdate:(NSString*)statusString delegate:(id<FBStatusUpdateRequestDelegate>)delegate {
	FBStatusUpdateRequest* statusUpdateRequest = [[[FBStatusUpdateRequest alloc] init] autorelease];
	statusUpdateRequest.delegate = delegate;
	[statusUpdateRequest updateStatus:statusString];
	
	return statusUpdateRequest;
}

- (id)init {
	if (self = [super init]) {
		self.session = [FBSession session];
	}
	
	return self;
}

- (id)initWithSession:(FBSession*)theSession {
	if (self = [super init]) {
		self.session = theSession;
	}
	
	return self;
}

- (void)dealloc {
	[_statusText release];
	[_permissionRequest release];
	[_session release];
	[super dealloc];
}

- (void)updateStatus:(NSString*)status {
	_statusText = [status retain];
	_permissionRequest = [[FBPermissionRequest acquirePermission:kFacebookUpdateStatusPermissionName withSession:_session delegate:self] retain];
}

#pragma mark FBPermissionRequestDelegate Methods

- (void)permissionRequestWasGranted:(FBPermissionRequest*)permissionRequest {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: _statusText, @"status", @"true", @"status_includes_verb", nil];
	[[FBRequest requestWithDelegate:self] call:kFacebookUpdateStatusApiCallName params:params];
}

- (void)permissionRequestWasDenied:(FBPermissionRequest*)permissionRequest {
	[self informDelegateStatusUpdateFailed];
}

- (void)permissionRequest:(FBPermissionRequest*)permissionRequest didFailWithError:(NSError*)error {
	if ([_delegate respondsToSelector:@selector(permissionRequest:didFailWithError:)]) {
		[_delegate statusUpdateRequest:self didFailWithError:error];
	}
}

#pragma mark FBRequestDelegate Methods

- (void)request:(FBRequest*)request didLoad:(id)result {
	if ([[request method] isEqualToString:kFacebookUpdateStatusApiCallName]) {
		if ([(NSString*)result intValue] == 1) {
			[self informDelegateStatusUpdateWasSuccessful];
		} else {
			[self informDelegateStatusUpdateFailed];
		}
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	if ([_delegate respondsToSelector:@selector(statusUpdateRequest:didFailWithError:)]) {
		[_delegate statusUpdateRequest:self didFailWithError:error];
	}
}

#pragma mark Private

- (void)informDelegateStatusUpdateWasSuccessful {
	if ([_delegate respondsToSelector:@selector(statusUpdateRequestWasSuccessful:)]) {
		[_delegate statusUpdateRequestWasSuccessful:self];
	}
}

- (void)informDelegateStatusUpdateFailed {
	if ([_delegate respondsToSelector:@selector(statusUpdateRequestFailed:)]) {
		[_delegate statusUpdateRequestFailed:self];
	}
}

@end
