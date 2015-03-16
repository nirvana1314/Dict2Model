//
//  Model.swift
//  0303-字典转模型
//
//  Created by 李松涛 on 15/3/3.
//  Copyright (c) 2015年 lst. All rights reserved.
//

import Foundation

class Model: NSObject, DictModelProtocol {
    var str1: String?
    var str2: NSString?
    var b: Bool = true
    var i: Int = 0
    var f: Float = 0
    var d: Double = 0
    var num: NSNumber?
    var info: Info?
    var other: [Info]?
    var others: NSArray?
    var demo: NSArray?
    //计算属性使用了class,之前用的static
    class func customClassMapping() -> [String: String]? {
        return ["info": "\(Info.self)", "other": "\(Info.self)", "others": "\(Info.self)", "demo": "\(Info.self)"]
    }
}

class SubModel: Model {
    var boy: String?
    var girl: String?
}

class Info: NSObject {
    var name: String?
}