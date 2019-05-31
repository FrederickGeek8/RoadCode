//
//  Document.swift
//  RoadCode
//
//  Created by Frederick Morlock on 4/18/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    var documentContents: String?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return documentContents?.data(using: .utf8)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        guard let data = contents as? Data else { return }
        documentContents = String(data: data, encoding: .utf8)
    }
}

