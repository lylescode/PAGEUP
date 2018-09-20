//
//  DMActivityInstagram.m
//  DMActivityInstagram
//
//  Created by Cory Alder on 2012-09-21.
//  Copyright (c) 2012 Cory Alder. All rights reserved.
//

#import "DMActivityInstagram.h"

@implementation DMActivityInstagram

- (NSString *)activityType {
    return @"UIActivityTypePostToInstagram";
}

- (NSString *)activityTitle {
    return @"Instagram";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ActivityIconInstagram"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) return NO; // no instagram.
    
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) self.shareImage = item;
        else if ([item isKindOfClass:[NSString class]]) {
            self.shareString = [(self.shareString ? self.shareString : @"") stringByAppendingFormat:@"%@%@",(self.shareString ? @" " : @""),item]; // concat, with space if already exists.
        }
        else if ([item isKindOfClass:[NSURL class]]) {
          if (self.includeURL) {
            self.shareString = [(self.shareString ? self.shareString : @"") stringByAppendingFormat:@"%@%@",(self.shareString ? @" " : @""),[(NSURL *)item absoluteString]]; // concat, with space if already exists.
          }
        }
        else NSLog(@"Unknown item type %@", item);
    }
}

- (UIViewController *)activityViewController {
    // resize controller if resize is required.
    return nil;
}

- (void)performActivity {
    // no resize, just fire away.
    //UIImageWriteToSavedPhotosAlbum(item.image, nil, nil, nil);
    
    NSData *imageData = UIImagePNGRepresentation(self.shareImage);
    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    if (![imageData writeToFile:imagePath atomically:YES]) {
        NSLog(@"Failed to preview image data to disk");
    } else {
        NSLog(@"preview image URL %@", imageURL);
    }
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
        self.documentController.UTI = @"com.instagram.exclusivegram";
        self.documentController.delegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.targetView animated:YES];
        } else {
            [self.documentController presentOpenInMenuFromRect:CGRectMake(self.targetView.frame.size.width/2, self.targetView.frame.size.height/2, 0, 0) inView:self.targetView animated:YES];
        }
        
    }
    
    
}


- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    [self activityDidFinish:YES];
}

-(BOOL)imageIsLargeEnough:(UIImage *)image {
    CGSize imageSize = [image size];
    return ((imageSize.height * image.scale) >= 612 && (imageSize.width * image.scale) >= 612);
}

-(BOOL)imageIsSquare:(UIImage *)image {
    CGSize imageSize = image.size;
    return (imageSize.height == imageSize.width);
}

-(void)activityDidFinish:(BOOL)success {
    NSError *error = nil;
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"instagram.igo"];
    if (![[NSFileManager defaultManager] removeItemAtPath:writePath error:&error]) {
        NSLog(@"Error cleaning up temporary image file: %@", error);
    }
    [super activityDidFinish:success];
}

@end
