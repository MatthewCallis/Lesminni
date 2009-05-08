
#import "ListManagedObject.h"
#import "LesminniAppDelegate.h"

@implementation ListManagedObject

- (NSData *) getIcon{
//	Leaking...
	[self willAccessValueForKey:@"icon"];
	iconData = [self primitiveValueForKey:@"icon"];
	[self didAccessValueForKey:@"icon"];
	if(iconData == nil){
		iconData = [[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list-small" ofType:@"png"]] retain];
	}

	return iconData;
}

- (void) setIcon: (NSData *) icon{
//	Leak
	if(icon == nil) icon = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list-small" ofType:@"png"]];

	[self willChangeValueForKey:@"icon"];
	[self setPrimitiveValue:icon forKey:@"icon"];
	[self didChangeValueForKey:@"icon"];
}

- (NSArray *) getRoms{
	return [[self valueForKey:@"items"] allObjects];
}

- (NSString *)getRomCount{
	return [NSString stringWithFormat:@"%i",[[[self valueForKey:@"items"] allObjects] count]];
}

- (NSScriptObjectSpecifier *) objectSpecifier{
	LesminniAppDelegate *delegate = [[NSApplication sharedApplication] delegate];
	NSIndexSpecifier *specifier = [[NSIndexSpecifier alloc]
									initWithContainerClassDescription:(NSScriptClassDescription *)[NSScriptClassDescription classDescriptionForClass:[delegate class]]
									containerSpecifier:[delegate objectSpecifier]
									key:@"romlists"];

	return specifier;
}

- (BOOL)getCanAdd{
	return YES;
}

- (void)setCanAdd:(BOOL)canAdd{}

- (void)setName:(NSString*)name{
	[self willChangeValueForKey:@"name"];
	[self setPrimitiveValue:name forKey:@"name"];
	[self didChangeValueForKey:@"name"];
}

- (NSString *)getName{
//	return [ListNameString stringWithString:[self primitiveValueForKey:@"name"]];
	return [self primitiveValueForKey:@"name"];
}

- (NSString *)getAuthor{
//	return [ListNameString stringWithString:[self primitiveValueForKey:@"author"]];
	return [self primitiveValueForKey:@"author"];
}

- (void)setAuthor:(NSString*)author{
	[self willChangeValueForKey:@"author"];
	[self setPrimitiveValue:author forKey:@"author"];
	[self didChangeValueForKey:@"author"];
}

- (NSString *)getVersion{
//	return [ListNameString stringWithString:[self primitiveValueForKey:@"version"]];
	return [self primitiveValueForKey:@"version"];
}

- (void)setVersion:(NSString*)version{
	[self willChangeValueForKey:@"version"];
	[self setPrimitiveValue:version forKey:@"version"];
	[self didChangeValueForKey:@"version"];
}

@end
