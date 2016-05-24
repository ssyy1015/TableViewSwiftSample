//
//  ViewController.swift
//  TableViewSwiftSample
//
//  Created by 佐藤悠翔 on 2016/03/14.
//  Copyright © 2016年 wanwano. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    //tableView中身配列
    var tableArray:NSArray!
    
// MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self;
        tableView.dataSource = self;
    
        //表示配列の生成
        tableArray = [
            ["team_name":"EFチーム",
                "members":["伊藤","佐藤","Alex"]],
            ["team_name":"ソラニワチーム",
                "members":["宮崎","山下"]],
        ]
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - UITableViewDataSource

    /**
     セクション数返却
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableArray.count; //今は適当に1返却
    }

    /** 
     セクション毎のセル数を返却
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let team = tableArray[section]
        let members:NSArray = team["members"] as! NSArray
        
        return members.count;
    }
    
    /**
     セクションのタイトルを返却
     */
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let team = tableArray[section]
        let teamName = team["team_name"]
        
        return teamName as? String;
    }
    
    /**
     indexPathに応じたセルを返却
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        //セルの生成
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        //membersを取得
        let team = tableArray[indexPath.section]
        let members:NSArray = team["members"] as! NSArray
        
        //タイトルの設定
        cell.textLabel?.text = members[indexPath.row] as? String
        
        return cell
    }
    
    
}

