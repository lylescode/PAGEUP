//
//  Project.h
//  Page
//
//  Created by CMR on 5/6/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Project : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * modificationDate;
@property (nonatomic, retain) NSString * previewImageName;
@property (nonatomic, retain) NSString * previewImageSize;

@property (nonatomic, retain) NSData * templateDictionaryData;
@property (nonatomic, retain) NSData * templateTextDictionaryData;
@property (nonatomic, retain) NSData * photoAssetDictionaryData;
@property (nonatomic, retain) NSData * projectDictionaryData;

- (NSDictionary *)templateDictionary;
- (void)setTemplateDictionary:(NSDictionary *)dictionary;


- (NSDictionary *)templateTextDictionary;
- (void)setTemplateTextDictionary:(NSDictionary *)dictionary;


- (NSDictionary *)projectDictionary;
- (void)setProjectDictionary:(NSDictionary *)dictionary;

- (NSArray *)photoAssetDictionaryArray;
- (void)setPhotoAssetDictionary:(NSArray *)array;


@end
