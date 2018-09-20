//
//  GeniusFontData.m
//  Page
//
//  Created by CMR on 9/11/15.
//  Copyright © 2015 Page. All rights reserved.
//

#import "GeniusFontData.h"

@implementation GeniusFontData

- (id)init
{
    self = [super init];
    if (self) {
        
        self.koreanTitleFonts =
        @[
          @"AppleSDGothicNeo-Regular",
          @"AppleSDGothicNeo-Bold",
          @"BM-HANNAStd",
          @"BMJUAOTF",
          @"BMDoHyeon-OTF",
          ];
        self.koreanContentFonts =
        @[
          @"AppleSDGothicNeo-Regular",
          @"AppleSDGothicNeo-Bold",
          @"BM-HANNAStd",
          @"BMJUAOTF",
          @"BMDoHyeon-OTF",
          ];
        
        self.defaultTitleFonts =
        @[
          @"Avenir-Heavy",
          @"Baskerville",
          @"AvenirNextCondensed-Bold",
          @"BodoniSvtyTwoITCTT-Bold",
          @"Courier",
          @"Futura-Medium",
          @"HelveticaNeue-Light",
          @"HelveticaNeue-Bold",
          @"LoveloLineLight",
          @"LoveloBlack",
          @"Superclarendon-Bold",
          @"Didot-Bold",
          @"DINCondensed-Bold",
          @"BloggerSans-Medium",
          @"ArialRoundedMTBold",
          @"Futura-CondensedExtraBold",
          ];
        
        self.defaultContentFonts =
        @[
          @"HelveticaNeue-Medium",
          @"Futura-Medium",
          @"TimesNewRomanPSMT",
          @"Avenir-Medium",
          @"DINAlternate-Bold",
          @"Georgia",
          @"Menlo-Regular"
          ];
        
        
        
        NSArray *koreanFonts =
        @[
          @[
              @"AppleSDGothicNeo-Regular",
              @"HelveticaNeue"
              ],
          @[
              @"AppleSDGothicNeo-Bold",
              @"HelveticaNeue"
              ],
          @[
              @"BM-HANNAStd",
              @"HelveticaNeue"
              ],
          @[
              @"BMJUAOTF",
              @"HelveticaNeue"
              ],
          @[
              @"BMDoHyeon-OTF",
              @"HelveticaNeue"
              ],
          ];
        
        NSArray *defaultFonts =
        @[
          @[
              @"BloggerSans-Medium",
              @"BloggerSans-Light"
              ],
          @[
              @"BebasNeueBold",
              @"BebasNeueLight",
              @"HelveticaNeue"
              ],
          @[
              @"HelveticaNeue-Bold",
              @"HelveticaNeue"
            ],
          @[
              @"DINCondensed-Bold",
              @"HelveticaNeue-Medium",
              @"Georgia"],
          @[
              @"HelveticaNeue-Medium",
              @"Didot-Bold",
              @"HelveticaNeue"
              ],
          @[
              @"AvenirNextCondensed-DemiBold",
              @"AvenirNextCondensed-Medium",
              @"HelveticaNeue"
              ],
          @[
              @"HelveticaNeue-Bold",
              @"HelveticaNeue-Medium",
              @"HelveticaNeue"
              ],
          @[
              @"TimesNewRomanPSMT",
              @"HelveticaNeue"
              ],
          @[
              @"Didot-Bold",
              @"HelveticaNeue-Bold",
              @"HelveticaNeue"
              ],
          @[
              @"BodoniSvtyTwoITCTT-Bold",
              @"HelveticaNeue-Bold",
              @"HelveticaNeue"
              ],
          @[
              @"BodoniSvtyTwoITCTT-Book",
              @"HelveticaNeue",
              @"HelveticaNeue"
              ],
          @[
              @"Didot",
              @"HelveticaNeue-Bold",
              @"HelveticaNeue"
              ],
          @[
              @"HelveticaNeue-Bold",
              @"BodoniSvtyTwoITCTT-Book"
              ],
          @[
              @"Didot",
              @"AvenirNextCondensed-Medium",
              @"HelveticaNeue"
              ],
          @[
              @"HelveticaNeue-Thin",
              @"HelveticaNeue-Medium"
              ]
          
          ];
        
        /*
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
         */
        self.fontDictionaryArray = [NSArray arrayWithArray:defaultFonts];
        self.koFontDictionaryArray = [NSArray arrayWithArray:koreanFonts];
        /*
         NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
         self.fontDictionaryArray = [self.fontDictionaryArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
         */
    }
    return self;
}
@end
