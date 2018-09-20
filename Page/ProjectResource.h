//
//  ProjectResource.h
//  Page
//
//  Created by CMR on 11/20/14.
//  Copyright (c) 2014 Page. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "Project.h"
#import "PTemplate.h"
#import "PPhotoAsset.h"

static NSInteger const ProjectResourceMaxPhotoCount = 4;
static CGSize ResultSize;

@interface ProjectResource : NSObject

@property (strong, nonatomic) NSString          *projectType;
@property (strong, nonatomic) NSString          *titleString;

@property (strong, nonatomic) Project *project;

@property (strong, nonatomic) NSString *locationString;

/*
 templateDictionary
 
 (TemplateData 클래스에서 생성됨)
 템플릿 정보를 담고 있음 NibName, PhotoViewCount, Ratio
 */
@property (strong, nonatomic) NSDictionary      *templateDictionary;

/*
 templateTextDictionary
 
 템플릿에 입력된 title, subtitle, date, description, footer, photoTitles, photoDescriptions 를 담고 있음
 (PTemplate 클래스에서 생성됨)
 */
@property (strong, nonatomic) NSDictionary      *templateTextDictionary;

/*
 projectDictionary
 
 템플릿에 포함되어있는 TextGroup, PPhotoView 정보를 담고 있음
 (PTemplate 클래스에서 생성됨)
 
 TextGroup - Label 의 Class, Frame, Tag, Text, FontName, FontSize, (NSString *)TextColor, Alignment 가 포함되어있고
 PPhotoView - Class, Frame, Tag, PhotoScale, PhotoTranslation
 */
@property (strong, nonatomic) NSDictionary      *projectDictionary;

@property (strong, nonatomic) NSMutableArray    *photoArray;

@property (strong, nonatomic) NSArray *photoColorSchemeArray;

/*
 photoAssetDictionaryArray
 
 PPhotoAsset 을 담고 있음
 (PPhotoAsset 에서 생성된 photoAssetDictionary 를 배열로 생성함)
 
 [ProjectResource updatePhotoAssetDictionary] 실행하면 생성됨
 PPhotoAsset - localIdentifier, cacheImageName, cacheThumbnailName
 */
@property (strong, nonatomic) NSMutableArray    *photoAssetDictionaryArray;

@property (assign, nonatomic) BOOL              updatedPhotos;

- (void)prepareForSaveProject;
- (void)setupPhotoAssetsWithPhotoAssetDictionaryArray:(NSArray *)dictionaryArray;
- (BOOL)shouldAddPhotoAsset;
- (BOOL)addedPhotoAsset:(PHAsset *)asset;

- (void)updatePhotoAssetDictionary;
- (NSInteger)indexOfPhotoAsset:(PHAsset *)asset;

- (void)addPhotoAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage completion:(void(^)(void))callback;
- (void)replaceAssetAtIndex:(NSInteger)assetIndex withAsset:(PHAsset *)asset thumbnailImage:(UIImage *)thumbnailImage completion:(void(^)(void))callback;
- (void)removePhotoAsset:(PHAsset *)asset;
- (void)removePhotoAssetWithIndex:(NSInteger)assetIndex;
- (void)movePhotoAssetAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)swapPhotoAssetsAtIndex:(NSInteger)aIndex bIndex:(NSInteger)bIndex;

- (void)removeAllPhotoAssetCachedImageFiles;
- (NSArray *)photoColorSchemes;

- (UIImage *)resultImage;
- (NSURL *)resultPDF;
@end