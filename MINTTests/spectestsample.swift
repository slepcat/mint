//
//  spectestsample.swift
//  MINT
//
//  Created by NemuNeko on 2015/05/02.
//  Copyright (c) 2015年 Taizo A. All rights reserved.
//

import Quick
import Nimble
import Foundation


class SampleSpec : QuickSpec {
    override func spec() {
        it("my first test") {
            let leafID = 0
            let leaf = Leaf(newID: leafID)
            
            expect(leaf.name).to(equal("null_leaf"))
        }
    }
}