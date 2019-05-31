//
//  UITextFieldExtension.swift
//  RoadCode
//
//  Created by Frederick Morlock on 5/14/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import Foundation
import UIKit
import Highlightr
import ActionSheetPicker_3_0

extension UITextView {
    @objc
    func insertTab() {
        self.replace(self.selectedTextRange!, withText: "\t")
    }
    
    @objc
    func changeLanguage() {
        let languages = Highlightr()?.supportedLanguages()
        let selected = languages?.index(of: UserDefaults.standard.string(forKey: "language") ?? "swift") ?? 0
        
        ActionSheetStringPicker.show(withTitle: "Pick a Language",
                                     rows: languages,
                                     initialSelection: selected,
                                     doneBlock:
            { picker, index, value in
                let defaults = UserDefaults.standard
                defaults.set(value! as! String, forKey: "language")
        },
                                     cancel: nil,
                                     origin: self.inputAccessoryView)
    }
    
    func addDoneButtonToKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let fontSize:CGFloat = 30;
        let font:UIFont = UIFont.boldSystemFont(ofSize: fontSize);
        
        let tabin = UIBarButtonItem(title: "⇥", style: .plain, target: self, action: #selector(insertTab))
        tabin.setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): font], for: .normal)
        let language = UIBarButtonItem(title: "Language", style: .plain, target: self, action: #selector(changeLanguage))
        
        var items = [UIBarButtonItem]()
        items.append(tabin)
        items.append(language)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
