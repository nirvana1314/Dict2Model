//
//  SwiftDictModel.swift
//  0303-字典转模型
//
//  Created by 李松涛 on 15/3/3.
//  Copyright (c) 2015年 lst. All rights reserved.
//

import Foundation

///  字典转模型自定义对象的协议
// 在 Swift 中，如果希望让类动态调用协议方法，需要使用 @objc 的关键字(即anyclass开始不存在custom方法,但允许程序运行后检测传入的class是否有这个方法)
@objc public protocol DictModelProtocol {
    
    static func customClassMapping() -> [String: String]?
}

public class SwiftDictModel {
    
    static let sharedManager = SwiftDictModel()
    
    ///  将字典转换成模型对象
    ///
    ///  :param: dict 数据字典
    ///  :param: cls  模型类
    ///
    ///  :returns: 实例化的类对象
    public func objectWithDictionary(dict: NSDictionary, cls: AnyClass) -> AnyObject? {
        
        //1.取出模型类的字典
        var modelInfo = fullModelInfo(cls)
        //实例化对象
        var obj: AnyObject = cls.alloc()
        
        // 2. 遍历模型字典，有什么属性就设置什么属性
        // k 应该和 dict 中的 key 是一致的
        // v是模型字典的信息
        // value是dict字典传入的真实数据
        for (k, v) in modelInfo {
            if let value: AnyObject? = dict[k] {
                if v.isEmpty && !(value === NSNull()) {
                    obj.setValue(value, forKey: k)
                }else {//自定义对象
                    //根据value中具体数据获取真实类名 {"name": "zhangsan"} -> NSDictionary
                    let type = "\(value!.classForCoder)"
//                    println("\t自定义对象: \(value) kkkkkk:\(k) vvvvvv:\(v) ---- type: \(type)")
                    //type == 字典或数组
                    if type == "NSDictionary" {
                        if let subObj: AnyObject? = objectWithDictionary(value as! NSDictionary, cls: NSClassFromString(v)) {
                            //subObj存在,将subObj赋给obj,并以k为键值
                            obj.setValue(subObj, forKey: k)
                        }
                    }else if type == "NSArray" {
                        if let subObj: AnyObject? = objectWithArray(value as! NSArray, cls: NSClassFromString(v)) {
                            obj.setValue(subObj, forKey: k)
                        }
                    }
                }
            }
        }
        
        return obj
    }
    
    ///  将数组转换成模型数组
    ///
    ///  :param: array 数组的描述
    ///  :param: cls 模型类
    ///
    ///  :returns: 模型数组
    public func objectWithArray(array: NSArray, cls: AnyClass) -> [AnyObject]?{
        
        // 创建一个数组
        var result = [AnyObject]()
        
        // 1. 遍历数组
        // 可能存在什么类型？字典/数组
        for value in array {
            let type = "\(value.classForCoder)"
            
            if type == "NSDictionary" {
                if let subObj: AnyObject = objectWithDictionary(value as! NSDictionary, cls: cls) {
                    //subObj存在,将subObj赋给obj,并以k为键值
                    result.append(subObj)
                }
            }else if type == "NSArray" {
                    if let subObj: AnyObject = objectWithArray(value as! NSArray, cls: cls) {
                        result.append(subObj)
                    }
            }
        }

        return result
    }
    
    /// 缓存字典
    var cache = [String: [String: String]]()
    
    ///2.获取模型类的完整信息
    ///
    ///  :param: cls 模型类
    func fullModelInfo(cls: AnyClass) -> [String: String] {
        
        
        if cache["\(cls)"] != nil {
            println("\(cls)类已被缓存")
            return cache["\(cls)"]!
        }
        
        // 循环查找父类
        // 1. 记录参数
        // 2. 循环中不会处理 NSObject
        var currentCls: AnyClass = cls
        
        var dict = [String: String]()
        while let parentCls: AnyClass = currentCls.superclass() {
            
            dict.merge(modelInfo(currentCls))
            
//            println("while\(modelInfo(currentCls))")
            currentCls = parentCls

        }
        //缓存字典
        cache["\(cls)"] = dict
        
        return dict
    }
    
    ///1.获取给定类的信息
    func modelInfo(cls: AnyClass) -> [String: String] {
        
        var mapping: [String: String]?
        if cls.respondsToSelector("customClassMapping") {
//            println("实现了协议方法")
            
            mapping = cls.customClassMapping()
//            println("mapping:\(mapping)")
        }
        
        /// 获取模型类属性
        var count: UInt32 = 0
        let ivars = class_copyIvarList(cls, &count)
//        println("\(count)个属性")
        
        // 定义一个模型类属性的字典 [属性名称：自定对象的名称/""]
        var dict = [String: String]()
        
        // 获取每个属性的信息：属性的名字，类型
        for i in 0..<count {
            let cname = ivar_getName(ivars[Int(i)])
            let name = String.fromCString(cname)!
            
            let type = mapping?[name] ?? ""
            dict[name] = type
        }
        
        free(ivars)

        return dict
    }
}

extension Dictionary {
    ///  将给定的字典（可变的）合并到当前字典
    ///  mutating 表示函数操作的字典是可变类型的
    ///  泛型(随便一个类型)，封装一些函数或者方法，更加具有弹性
    ///  任何两个 [key: value] 类型匹配的字典，都可以进行合并操作
    
    mutating func merge<K, V>(dict: [K: V]) {
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

