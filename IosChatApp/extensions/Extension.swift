//
//  Extension.swift
//  IosChatApp
//
//  Created by dremobaba on 2023/2/20.
//

import Foundation
import SwiftUI

extension Font {
    static var welcome: Font {
        boldFont(27)
    }
    static var signupTitle: Font {
        boldFont(27)
    }
    static var welcomeBtn: Font {
       regularFont(16)
    }
    static var welcomeDesc: Font {
        regularFont(18)
    }
    static var secondaryMedium: Font {
        regularFont(18)
    }
    static var primaryBold: Font {
        boldFont(18)
    }
    static var secondaryText: Font {
        regularFont(16)
    }
    static var secondaryBold: Font {
        boldFont(16)
    }
    
    private static func regularFont(_ size: CGFloat) -> Font {
        return .custom("ProximaNova-Regular", size: size)
    }
    private static func boldFont(_ size: CGFloat) -> Font {
        return .custom("ProximaNova-Bold", size: size)
    }
}
