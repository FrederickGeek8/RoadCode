//
//  LanguageBridge.swift
//  RoadCode
//
//  Created by Frederick Morlock on 5/14/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import Foundation
import Highlightr

@objc
class LanguageBridge :NSObject {
    @objc
    func setLanguage(input: CodeAttributedString, language: String) {
        input.language = language
    }
}
