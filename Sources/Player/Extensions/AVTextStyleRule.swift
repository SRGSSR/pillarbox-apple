//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVTextStyleRule {
    /// Creates a text style rule object with the specified style attributes and text range information.
    ///
    /// - Parameters:
    ///   - textMarkupAttributes: A dictionary of style attributes. For a list of supported keys look for constants
    ///     starting with `kCMTextMarkupAttribute`.
    ///   - textSelector: A string contains an identifier for the ranges of text to which the style attributes should
    ///     be applied. Eligible identifiers are determined by the media format and its corresponding text content.
    ///     For example, the string could contain the CSS selectors used by the corresponding text in Web Video Text
    ///     Tracks (WebVTT) markup. Specify nil if you want the style attributes to apply to all text in the item.
    convenience init(textMarkupAttributes: [CFString: Any] = [:], textSelector: String? = nil) {
        self.init(textMarkupAttributes: textMarkupAttributes as [String: Any], textSelector: textSelector)!
    }
}
