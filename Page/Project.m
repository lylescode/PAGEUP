//
//  Project.m
//  Page
//
//  Created by CMR on 5/6/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "Project.h"


@implementation Project

@dynamic creationDate;
@dynamic modificationDate;
@dynamic previewImageName;
@dynamic previewImageSize;

@dynamic templateDictionaryData;
@dynamic templateTextDictionaryData;

@dynamic photoAssetDictionaryData;
@dynamic projectDictionaryData;

- (NSDictionary *)templateDictionary
{
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:self.templateDictionaryData];
    return dictionary;
}

- (void)setTemplateDictionary:(NSDictionary *)dictionary
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    self.templateDictionaryData = data;
}


- (NSDictionary *)templateTextDictionary
{
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:self.templateTextDictionaryData];
    return dictionary;
}

- (void)setTemplateTextDictionary:(NSDictionary *)dictionary
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    self.templateTextDictionaryData = data;
}


- (NSDictionary *)projectDictionary
{
    NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:self.projectDictionaryData];
    return dictionary;
}

- (void)setProjectDictionary:(NSDictionary *)dictionary
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    self.projectDictionaryData = data;
}

- (NSArray *)photoAssetDictionaryArray
{
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:self.photoAssetDictionaryData];
    return array;
}

- (void)setPhotoAssetDictionary:(NSArray *)array
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    self.photoAssetDictionaryData = data;
}

@end
