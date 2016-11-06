//
//  FilterOperation.swift
//  swift-multithreading-lab
//
//  Created by Jhantelle Belleza on 11/6/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import Foundation
import UIKit

class FilterOperation: Operation {
    var flatigram: Flatigram
    var filter: String
    
    init(flatigram: Flatigram, filter: String) {
        self.flatigram = flatigram
        self.filter = filter
    }
    
    override func main() {
        guard let unwrappedImage = flatigram.image?.filter(with: filter) else { return }
        self.flatigram.image = unwrappedImage
    }
}
