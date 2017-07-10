//
//  ViewModel.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import Foundation

struct ViewModel : Diffable {
    
    var diffIdentifier: String = ""
}

struct Group : SectionDiffable {
    
    var diffIdentifier: String = ""
    
    var sectionItems: Array<Diffable> = [Diffable]()
    
    init(section:String, rows:[String]) {
        self.diffIdentifier = section
        for str in rows {
            self.sectionItems.append(ViewModel(diffIdentifier: str))
        }
    }
}

func randomData() -> [Group] {
    let array = [testDatas1(), testDatas2(), testDatas3(), testDatas4(), testDatas5(), testDatas6()]
    let num = arc4random_uniform(6)
    return array[Int(num)]
}

func testDatas1() -> [Group] {
    var groups = [Group]()
    groups.append(Group.init(section: "section1", rows: ["1","2","3","4","5","6"]))
    groups.append(Group.init(section: "section2", rows: ["7","8","9","10","11","12"]))
    return groups
}

func testDatas2() -> [Group] {
    var groups = [Group]()
    groups.append(Group.init(section: "section1", rows: ["1","2","3","4","5","6"]))
    return groups
}

func testDatas3() -> [Group] {
    var groups = [Group]()
    groups.append(Group.init(section: "section1", rows: ["1","2","3","4","5","6"]))
    groups.append(Group.init(section: "section2", rows: ["7","8","12"]))
    return groups
}

func testDatas4() -> [Group] {
    var groups = [Group]()
    groups.append(Group.init(section: "section1", rows: ["1","3","2","4","6"]))
    groups.append(Group.init(section: "section2", rows: ["7","8","9","10","5","11","12"]))
    return groups
}

func testDatas5() -> [Group] {
    var groups = [Group]()
    groups.append(Group.init(section: "section1", rows: ["1","2","3","4","9","6"]))
    groups.append(Group.init(section: "section2", rows: ["7","8","5","10","11","12"]))
    return groups
}

func testDatas6() -> [Group] {
    var groups = [Group]()
    groups.append(Group.init(section: "section1", rows: ["7","10","8","12","9","11"]))
    groups.append(Group.init(section: "section2", rows: ["4","1","5","3","2","6"]))
    return groups
}
