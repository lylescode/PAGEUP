//
//  FontData.m
//  Page
//
//  Created by CMR on 9/1/15.
//  Copyright (c) 2015 Page. All rights reserved.
//

#import "FontData.h"

@implementation FontData

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *koreanFonts =
        @[
          
          @{@"fontName": @"AppleSDGothicNeo-Regular",
            @"displayName": @"AppleSDGothicNeo Regular"},
          
          @{@"fontName": @"AppleSDGothicNeo-Bold",
            @"displayName": @"AppleSDGothicNeo Bold"},
          
          
          @{@"fontName": @"BM-HANNAStd",
            @"displayName": @"HANNA"},
          
          @{@"fontName": @"BMJUAOTF",
            @"displayName": @"JUA"},
          
          @{@"fontName": @"BMDoHyeon-OTF",
            @"displayName": @"DoHyeon"},
          
          ];
        
        NSArray *defaultFonts =
        @[
          @{@"fontName": @"ArialRoundedMTBold",
            @"displayName": @"ArialRounded MT Bold"},
          
          
          @{@"fontName": @"AmericanTypewriter-Light",
            @"displayName": @"AmericanTypewriter Light"},
          
          @{@"fontName": @"AmericanTypewriter-Bold",
            @"displayName": @"AmericanTypewriter Bold"},
          
          @{@"fontName": @"AmericanTypewriter-Condensed",
            @"displayName": @"AmericanTypewriter Condensed"},
          
          
          @{@"fontName": @"Avenir-Medium",
            @"displayName": @"Avenir Medium"},
          
          @{@"fontName": @"Avenir-MediumOblique",
            @"displayName": @"Avenir Medium Oblique"},
          
          @{@"fontName": @"Avenir-Light",
            @"displayName": @"Avenir Light"},
          
          @{@"fontName": @"Avenir-LightOblique",
            @"displayName": @"Avenir Light Oblique"},
          
          @{@"fontName": @"Avenir-Black",
            @"displayName": @"Avenir Black"},
          
          @{@"fontName": @"Avenir-BlackOblique",
            @"displayName": @"Avenir Black Oblique"},
          
          @{@"fontName": @"Avenir-Heavy",
            @"displayName": @"Avenir Heavy"},
          
          @{@"fontName": @"Avenir-HeavyOblique",
            @"displayName": @"Avenir Heavy Oblique"},
          
          
          @{@"fontName": @"AvenirNextCondensed-Regular",
            @"displayName": @"AvenirNextCondensed Regular"},
          
          @{@"fontName": @"AvenirNextCondensed-Italic",
            @"displayName": @"AvenirNextCondensed Italic"},
          
          @{@"fontName": @"AvenirNextCondensed-Bold",
            @"displayName": @"AvenirNextCondensed Bold"},
          
          @{@"fontName": @"AvenirNextCondensed-DemiBold",
            @"displayName": @"AvenirNextCondensed DemiBold"},
          
          @{@"fontName": @"AvenirNextCondensed-BoldItalic",
            @"displayName": @"AvenirNextCondensed Bold Italic"},
          
          @{@"fontName": @"AvenirNextCondensed-Medium",
            @"displayName": @"AvenirNextCondensed Medium"},
          
          @{@"fontName": @"AvenirNextCondensed-MediumItalic",
            @"displayName": @"AvenirNextCondensed Medium Italic"},
          
          @{@"fontName": @"AvenirNextCondensed-Heavy",
            @"displayName": @"AvenirNextCondensed Heavy"},
          
          @{@"fontName": @"AvenirNextCondensed-HeavyItalic",
            @"displayName": @"AvenirNextCondensed Heavy Italic"},
          
          
          @{@"fontName": @"Baskerville",
            @"displayName": @"Baskerville"},
          
          @{@"fontName": @"Baskerville-Italic",
            @"displayName": @"Baskerville Italic"},
          
          @{@"fontName": @"Baskerville-SemiBold",
            @"displayName": @"Baskerville SemiBold"},
          
          @{@"fontName": @"Baskerville-BoldItalic",
            @"displayName": @"Baskerville Bold Italic"},
          
          
          @{@"fontName": @"BebasNeueRegular",
            @"displayName": @"BebasNeue Regular"},
          
          @{@"fontName": @"BebasNeueLight",
            @"displayName": @"BebasNeue Light"},
          
          @{@"fontName": @"BebasNeueBold",
            @"displayName": @"BebasNeue Bold"},
          
          
          @{@"fontName": @"BloggerSans-Light",
            @"displayName": @"BloggerSans Light"},
          
          @{@"fontName": @"BloggerSans-Medium",
            @"displayName": @"BloggerSans Medium"},
          
          @{@"fontName": @"BloggerSans-Bold",
            @"displayName": @"BloggerSans Bold"},
          
          /*
          @{@"fontName": @"Braxton",
            @"displayName": @"Braxton"},
          */
          
          @{@"fontName": @"BodoniSvtyTwoITCTT-Bold",
            @"displayName": @"BodoniSvtyTwoITCTT Bold"},
          
          @{@"fontName": @"BodoniSvtyTwoITCTT-Book",
            @"displayName": @"BodoniSvtyTwoITCTT Book"},
          
          @{@"fontName": @"BodoniSvtyTwoITCTT-BookIta",
            @"displayName": @"BodoniSvtyTwoITCTT Book Italic"},
          
          
          /*
          @{@"fontName": @"Canaro-LightDEMO",
            @"displayName": @"Canaro Light"},
          
          @{@"fontName": @"Canaro-LightItalicDEMO",
            @"displayName": @"Canaro Light Italic"},
          */
          
          
          @{@"fontName": @"CourierNewPSMT",
            @"displayName": @"Courier NewPSMT"},
          
          @{@"fontName": @"CourierNewPS-ItalicMT",
            @"displayName": @"Courier NewPSMT ItalicMT"},
          
          
          @{@"fontName": @"Courier",
            @"displayName": @"Courier"},
          
          @{@"fontName": @"Courier-Oblique",
            @"displayName": @"Courier Oblique"},
          
          @{@"fontName": @"Courier-Bold",
            @"displayName": @"Courier Bold"},
          
          @{@"fontName": @"Courier-BoldOblique",
            @"displayName": @"Courier Bold Oblique"},
          
          
          
          @{@"fontName": @"DINCondensed-Bold",
            @"displayName": @"DINCondensed Bold"},
          
          @{@"fontName": @"DINAlternate-Bold",
            @"displayName": @"DINAlternate Bold"},
          
          
          
          @{@"fontName": @"Didot",
            @"displayName": @"Didot"},
          
          @{@"fontName": @"Didot-Bold",
            @"displayName": @"Didot Bold"},
          
          @{@"fontName": @"Didot-Italic",
            @"displayName": @"Didot Italic"},
          
          
          
          @{@"fontName": @"Futura-Medium",
            @"displayName": @"Futura Medium"},
          
          @{@"fontName": @"Futura-MediumItalic",
            @"displayName": @"Futura Medium Italic"},
          
          @{@"fontName": @"Futura-CondensedMedium",
            @"displayName": @"Futura Condensed Medium"},
          
          @{@"fontName": @"Futura-CondensedExtraBold",
            @"displayName": @"Futura Condensed ExtraBold"},
          
          
          
          @{@"fontName": @"Georgia",
            @"displayName": @"Georgia"},
          
          @{@"fontName": @"Georgia-Italic",
            @"displayName": @"Georgia Italic"},
          
          @{@"fontName": @"Georgia-Bold",
            @"displayName": @"Georgia Bold"},
          
          @{@"fontName": @"Georgia-BoldItalic",
            @"displayName": @"Georgia Bold Italic"},
          
          
          @{@"fontName": @"Helvetica",
            @"displayName": @"Helvetica"},
          
          @{@"fontName": @"Helvetica-Light",
            @"displayName": @"Helvetica Light"},
          
          @{@"fontName": @"Helvetica-Bold",
            @"displayName": @"Helvetica Bold"},
          
          
          @{@"fontName": @"HelveticaNeue",
            @"displayName": @"Helvetica Neue"},
          
          @{@"fontName": @"HelveticaNeue-Italic",
            @"displayName": @"HelveticaNeue Italic"},
          
          @{@"fontName": @"HelveticaNeue-Medium",
            @"displayName": @"HelveticaNeue Medium"},
          
          @{@"fontName": @"HelveticaNeue-MediumItalic",
            @"displayName": @"HelveticaNeue Medium Italic"},
          
          @{@"fontName": @"HelveticaNeue-Bold",
            @"displayName": @"HelveticaNeue Bold"},
          
          @{@"fontName": @"HelveticaNeue-BoldItalic",
            @"displayName": @"HelveticaNeue Bold Italic"},
          
          @{@"fontName": @"HelveticaNeue-Light",
            @"displayName": @"HelveticaNeue Light"},
          
          @{@"fontName": @"HelveticaNeue-LightItalic",
            @"displayName": @"HelveticaNeue Light Italic"},
          
          @{@"fontName": @"HelveticaNeue-Thin",
            @"displayName": @"HelveticaNeue Thin"},
          
          @{@"fontName": @"HelveticaNeue-ThinItalic",
            @"displayName": @"HelveticaNeue Thin Italic"},
          
          @{@"fontName": @"HelveticaNeue-UltraLight",
            @"displayName": @"HelveticaNeue UltraLight"},
          
          @{@"fontName": @"HelveticaNeue-UltraLightItalic",
            @"displayName": @"HelveticaNeue UltraLight Italic"},
          
          @{@"fontName": @"HelveticaNeue-CondensedBold",
            @"displayName": @"HelveticaNeue CondensedBold"},
          
          @{@"fontName": @"HelveticaNeue-CondensedBlack",
            @"displayName": @"HelveticaNeue CondensedBlack"},
          
          
          @{@"fontName": @"HiraKakuProN-W3",
            @"displayName": @"HiraKakuProN W3"},
          
          
          
          @{@"fontName": @"IowanOldStyle-Roman",
            @"displayName": @"IowanOldStyle Roman"},
          
          @{@"fontName": @"IowanOldStyle-Italic",
            @"displayName": @"IowanOldStyle Italic"},
          
          @{@"fontName": @"IowanOldStyle-Bold",
            @"displayName": @"IowanOldStyle Bold"},
          
          @{@"fontName": @"IowanOldStyle-BoldItalic",
            @"displayName": @"IowanOldStyle Bold Italic"},
          
          
          @{@"fontName": @"LoveloLineLight",
            @"displayName": @"Lovelo Light"},
          
          @{@"fontName": @"LoveloLineBold",
            @"displayName": @"Lovelo Bold"},
          
          @{@"fontName": @"LoveloBlack",
            @"displayName": @"Lovelo Black"},
          
          
          @{@"fontName": @"Metropolis1920",
            @"displayName": @"Metropolis 1920"},
          
          
          @{@"fontName": @"Menlo-Regular",
            @"displayName": @"Menlo Regular"},
          
          @{@"fontName": @"Menlo-Italic",
            @"displayName": @"Menlo Italic"},
          
          @{@"fontName": @"Menlo-Bold",
            @"displayName": @"Menlo Bold"},
          
          @{@"fontName": @"Menlo-BoldItalic",
            @"displayName": @"Menlo Bold Italic"},
          
          
          @{@"fontName": @"Palatino-Roman",
            @"displayName": @"Palatino Roman"},
          
          @{@"fontName": @"Palatino-Italic",
            @"displayName": @"Palatino Italic"},
          
          @{@"fontName": @"Palatino-Bold",
            @"displayName": @"Palatino Bold"},
          
          @{@"fontName": @"Palatino-BoldItalic",
            @"displayName": @"Palatino Bold Italic"},
          
          /*
          @{@"fontName": @"STHeitiTC-Medium",
            @"displayName": @"STHeitiTC"},
          
          @{@"fontName": @"STHeitiSC-Medium",
            @"displayName": @"STHeitiSC"},
          
          @{@"fontName": @"STHeitiJ-Medium",
            @"displayName": @"STHeitiJ"},
          */
          
          @{@"fontName": @"SavoyeLetPlain",
            @"displayName": @"SavoyeLetPlain"},
          
          
          @{@"fontName": @"Superclarendon-Regular",
            @"displayName": @"Superclarendon Regular"},
          
          @{@"fontName": @"Superclarendon-Italic",
            @"displayName": @"Superclarendon Italic"},
          
          @{@"fontName": @"Superclarendon-Bold",
            @"displayName": @"Superclarendon Bold"},
          
          @{@"fontName": @"Superclarendon-BoldItalic",
            @"displayName": @"Superclarendon Bold Italic"},
          
          
          @{@"fontName": @"TimesNewRomanPSMT",
            @"displayName": @"TimesNewRoman"},
          
          @{@"fontName": @"TimesNewRomanPS-ItalicMT",
            @"displayName": @"TimesNewRoman Italic"},
          
          @{@"fontName": @"TimesNewRomanPS-BoldMT",
            @"displayName": @"TimesNewRoman Bold"},
          
          @{@"fontName": @"TimesNewRomanPS-BoldItalicMT",
            @"displayName": @"TimesNewRoman Bold Italic"}
          ];

        
        NSMutableArray *allFonts;
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        if([language isEqualToString:@"ko"]) {
            allFonts = [NSMutableArray arrayWithArray:koreanFonts];
            [allFonts addObjectsFromArray:defaultFonts];
        }
        else {
            allFonts = [NSMutableArray arrayWithArray:defaultFonts];
            [allFonts addObjectsFromArray:koreanFonts];
        }
        self.fontDictionaryArray = [NSArray arrayWithArray:allFonts];
        
        /*
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        self.fontDictionaryArray = [self.fontDictionaryArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
         */
    }
    return self;
}


- (void)dealloc
{
    self.fontDictionaryArray = nil;
}

@end
