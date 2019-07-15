//
//  DocumentBrowserViewController.swift
//  RoadCode
//
//  Created by Frederick Morlock on 4/18/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view.
        let settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "Gear"), style: .done, target: self, action: #selector(showSettings))
        
        
        self.additionalLeadingNavigationBarButtonItems = [settingsBarButtonItem]
    }
    
    @objc
    func showSettings() {
        
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController")
        
        let navCon = UINavigationController(rootViewController: settingsVC)
        navCon.modalPresentationStyle = .formSheet
        
        self.present(navCon, animated: true, completion: nil)
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let alert = UIAlertController(title: "Create Document", message: "Please choose a filename", preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField) in
            textField.text = "Untitled.txt"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            importHandler(nil, .none)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let fileName = alert.textFields![0].text
            let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
            let newDocumentURL = tmp.appendingPathComponent(fileName!)
            
            do {
                try FileManager.default.copyItem(at: Bundle.main.url(forResource: "Untitled", withExtension: "txt")!, to: newDocumentURL)
            } catch _ {
                let fail = UIAlertController(title: "Failure", message: "Error creating file", preferredStyle: .alert)
                fail.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                importHandler(nil, .none)
            }
            
            importHandler(newDocumentURL, .copy)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
        
        let nav = UINavigationController(rootViewController: documentViewController)
        
        documentViewController.setDocument(Document(fileURL: documentURL)) {
            self.present(nav, animated: true, completion: nil)
        }
        
    }
}

