//
//  ViewController.swift
//  TableViewSwiftSample
//
//  Created by 佐藤悠翔 on 2016/03/14.
//  Copyright © 2016年 wanwano. All rights reserved.
//

import UIKit
import AFNetworking

class NewsCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    //tableView中身配列
    var tableArray:NSArray!
    
    // MARK: - ViewController

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.delegate = self;
        tableView.dataSource = self;
        
        let ud = NSUserDefaults.standardUserDefaults()
        let udToken:String? = ud.stringForKey("token")
        
        if udToken == nil {
            //registerProfileをコール
            self.registerProfile({ () -> Void in
                self.news()
            })
        }
        else {
            self.news()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private
    
    /**
    register_provisional
    */
    func registerProfile(success: (() -> Void)?) {
        //リクエスト
        let manager:AFHTTPSessionManager = AFHTTPSessionManager()
        let serializer:AFJSONResponseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer = serializer
        
        let uuid = NSUUID().UUIDString
        let params:NSDictionary = ["uuid":uuid,"ostype":"ios","_execution_mode":"dev"]
        
        manager.POST("https://ac-media-staging.api.everforth.com/2.0/LUCUAApp/register_provisional", parameters: params,
            progress: { (progress) -> Void in
                
            }, success: { (dataTask, response) -> Void in
                let resDic:NSDictionary! = response as! NSDictionary
                let token:String = resDic["data"]!["access_token"] as! String

                if token.characters.count > 0 {
                    let ud2 = NSUserDefaults.standardUserDefaults()
                    ud2.setObject(token, forKey: "token")
                    ud2.synchronize()
                    
                    if success != nil {
                        //newsAPIをコール
                        success!()
                    }
                    
                }
                
            }) { (dataTask, error) -> Void in
        }
    }
    
    /**
     newsAPI
     */
    func news() {
        let ud = NSUserDefaults.standardUserDefaults()
        let udToken:String? = ud.stringForKey("token")
        
        if udToken != nil {

            //リクエスト
            let manager:AFHTTPSessionManager = AFHTTPSessionManager()
            let serializer:AFJSONResponseSerializer = AFJSONResponseSerializer()
            manager.responseSerializer = serializer

            //ヘッダ
            let bearer = "Bearer "+udToken!
            manager.requestSerializer.setValue(bearer, forHTTPHeaderField:"Authorization")
            
            let params:NSDictionary = ["limit":"20","start":"0"]
            
            manager.GET("https://ac-media-staging.api.everforth.com/2.1/LUCUAApp/news", parameters: params,
                progress: { (progress) -> Void in
                    
                }, success: { (dataTask, response) -> Void in
                    let resDic:NSDictionary! = response as! NSDictionary
                    let data:NSArray?  = resDic["data"] as? NSArray
                    
                    if data != nil {
                        self.tableArray = data!
                        self.tableView.reloadData()
                    }
                    
                }) { (dataTask, error) -> Void in
                    
            }
        }
    }
    
    // MARK: - UITableViewDataSource

    /**
     セクション数返却
     */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    /** 
     セクション毎のセル数を返却
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count;
    }
    
    /**
     indexPathに応じたセルを返却
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        //セルの生成
        let cell:NewsCell! = tableView.dequeueReusableCellWithIdentifier("NewsCell", forIndexPath: indexPath) as? NewsCell
        
        //membersを取得
        let news:NSDictionary! = tableArray[indexPath.row] as? NSDictionary
        let image_url:String! = news["image_url"] as? String
        let title = news["title"]
        let public_at:String! = news["public_at"] as? String

        //初期化
        cell.titleLabel.text = nil
        cell.dateLabel.text = nil
        cell.thumbnailImageView.image = nil
        
        //タイトルの設定
        cell.titleLabel.text = title as? String
        
        //日付の設定
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        if public_at != nil {
            let str = formatter.dateFromString(public_at)
            formatter.dateFormat = "yyyy.MM.dd"

            cell.dateLabel.text = formatter.stringFromDate(str!)
        }
        
        //サムネイルの設定
        if image_url != nil {
            let url:NSURL = NSURL(string: image_url)!
            cell.thumbnailImageView.setImageWithURL(url)
        }
        
        return cell
    }
    
    
}

