//
//  ViewController.swift
//  0303-字典转模型
//
//  Created by 李松涛 on 15/3/3.
//  Copyright (c) 2015年 lst. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tools = SwiftDictModel.sharedManager
        let dict = loadJSON()
        let obj = tools.objectWithDictionary(dict, cls: Model.self) as! Model

        println("OTHER")
        for value in obj.other! {
            println(value.name!)
        }
        println("OTHERS")
        for value in obj.others! {
            let o = value as! Info
            println(o.name!)
        }
        
        println("Demo \(obj.demo!)")
        
        
    }

    func loadJSON() ->NSDictionary{
        let path = NSBundle.mainBundle().pathForResource("Model01.json", ofType: nil)
        let data = NSData(contentsOfFile: path!)
        return NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.allZeros, error: nil) as! NSDictionary
    }


}

