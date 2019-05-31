//
//  DocumentViewController.swift
//  RoadCode
//
//  Created by Frederick Morlock on 4/18/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit
import Highlightr

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var documentNameLabel: UILabel!
    
    
    var document: Document?
    var textView: UITextView?
    var text: String = ""
    var highlightr : Highlightr!
    var textStorage: CodeAttributedString!
    var oldContentInset = UIEdgeInsets.zero
    var oldIndicatorInset = UIEdgeInsets.zero
    var oldOffset = CGPoint.zero
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let back = UIButton(type: .system)
        back.setTitle("Done", for: .normal)
        back.addTarget(self, action: #selector(dismissDocumentViewController), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: back)
        
        let defaults = UserDefaults.standard
        self.textStorage = CodeAttributedString()
        self.highlightr = textStorage.highlightr

        self.textStorage.highlightr.setTheme(to: defaults.string(forKey: "theme") ?? "vs")
        self.textStorage.language = "Swift"
        let layoutManager = NSLayoutManager()
        self.textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: CGSize(width: 0.0, height: 0.0))
        layoutManager.addTextContainer(textContainer)
        
        self.textView = UITextView(frame: view.bounds, textContainer: textContainer)
        self.textView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.textView?.autocorrectionType = .no
        self.textView?.autocapitalizationType = .none
        self.textView?.spellCheckingType = .no
        self.textView?.smartQuotesType = .no
        self.textView?.smartDashesType = .no
        self.textView?.delegate = self
        self.textView?.text = self.text
        self.textView?.addDoneButtonToKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateColors()
        self.view.addSubview(self.textView!)
    }
    
    @objc
    func languageChanged() {
        self.textStorage.language = UserDefaults.standard.string(forKey: "language")
    }
    
    func setDocument(_ document: Document, completion: @escaping () -> Void) {
        self.document = document
        loadViewIfNeeded()
        
        document.open(completionHandler: {(success) in
            if success {
                self.navigationItem.title = self.document?.fileURL.lastPathComponent
                self.text = String(self.document?.documentContents ?? "")
            }
            completion()
        })
    }
    
    enum KeyboardState {
        case unknown
        case entering
        case exiting
    }
    
    func keyboardState(for d:[AnyHashable:Any], in v:UIView?) -> (KeyboardState, CGRect?) {
        var rold = d[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        var rnew = d[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        var ks : KeyboardState = .unknown
        var newRect : CGRect? = nil
        if let v = v {
            let co = UIScreen.main.coordinateSpace
            rold = co.convert(rold, to:v)
            rnew = co.convert(rnew, to:v)
            newRect = rnew
            if !rold.intersects(v.bounds) && rnew.intersects(v.bounds) {
                ks = .entering
            }
            if rold.intersects(v.bounds) && !rnew.intersects(v.bounds) {
                ks = .exiting
            }
        }
        return (ks, newRect)
    }
    
    @objc func keyboardShow(_ n:Notification) {
        let d = n.userInfo!
        let (state, rnew) = keyboardState(for:d, in:self.textView)
        if state == .entering {
            print("really showing")
            self.oldContentInset = self.textView!.contentInset
            self.oldIndicatorInset = self.textView!.scrollIndicatorInsets
            self.oldOffset = self.textView!.contentOffset
        }
        print("show")
        // no need to scroll, as the scroll view will do it for us
        // so all we have to do is adjust the inset
        if let rnew = rnew {
            let h = rnew.intersection(self.textView!.bounds).height
            self.textView!.contentInset.bottom = h
            self.textView!.scrollIndicatorInsets.bottom = h
        }
    }
    
    @objc func keyboardHide(_ n:Notification) {
        let d = n.userInfo!
        let (state, _) = keyboardState(for:d, in:self.textView)
        if state == .exiting {
            print("really hiding")
            // restore original setup
            // we _don't_ do this; let the text view position itself
            // self.scrollView.contentOffset = self.oldOffset
            self.textView!.scrollIndicatorInsets = self.oldIndicatorInset
            self.textView!.contentInset = self.oldContentInset
        }
    }
    
    @objc func dismissDocumentViewController() {
        dismiss(animated: true) {
            let currentText = self.document?.documentContents ?? ""
            self.document?.documentContents = self.textView?.text
            
            if currentText != self.textView?.text {
                self.document?.updateChangeCount(.done)
            }
            
            self.document?.close(completionHandler: nil)
        }
    }
    
    func updateColors()
    {
        self.textView?.backgroundColor = self.highlightr.theme.themeBackgroundColor
    }
    
    @objc
    func tab() {
        self.textView?.replace((self.textView?.selectedTextRange)!, withText: "\t")
    }
}

extension DocumentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let loc = String.Index(utf16Offset: range.location - 1, in: textView.text)
            if let lastIndex = textView.text[...loc].lastIndex(of: "\n") {
//                let offset = String.Index(utf16Offset: lastIndex.utf16Offset(in: textView.text) + range.location, in: textView.text)
                let substring = textView.text[lastIndex...]
                if let range = substring.range(of: #"^\s+"#, options: .regularExpression) {
                    self.textView?.replace((self.textView?.selectedTextRange)!, withText: String(substring[range]))
                    return false
                }
            }
            
        }
        return true
    }
}
