//
//  NewsDetailViewController.swift
//  TableViewSwiftSample
//
//  Created by 佐藤悠翔 on 2016/05/27.
//  Copyright © 2016年 wanwano. All rights reserved.
//

import UIKit
import AFNetworking

enum NewsDetailCellRows : Int{
    case Header = 0
    case Content
    case Count
}

class NewsDetailHeaderCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
}

class NewsDetailContentCell: UITableViewCell {
    @IBOutlet weak var contentTextView: UITextView!
}

class NewsDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var news:NSDictionary!
    var headerHTML:String!
    var footerHTML:String!

    // MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        
        self.tableView.estimatedRowHeight = 20
        self.tableView.rowHeight = UITableViewAutomaticDimension
     
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.newsCSS()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    
    func newsCSS() {
        //"http://media-ref.everforth.com/ac/sp-template/html.json?"
        //リクエスト
        let manager:AFHTTPSessionManager = AFHTTPSessionManager()
        let serializer:AFJSONResponseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer = serializer
        
        
        manager.GET("http://media-ref.everforth.com/ac/sp-template/html.json?", parameters: nil,
            progress: { (progress) -> Void in
                
            }, success: { (dataTask, response) -> Void in
                let resDic:NSDictionary! = response as! NSDictionary
                let data:NSDictionary?  = resDic["data"] as? NSDictionary
                
                if data != nil {
                    self.headerHTML = data!["header"] as? String
                    self.footerHTML = data!["footer"] as? String
                    self.tableView.reloadData()
                }
                
            }) { (dataTask, error) -> Void in
                
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
        
        //まだcssの取得が終わっていない場合にはcontentCellの表示をしない
        if self.headerHTML == nil && self.footerHTML == nil {
            return NewsDetailCellRows.Content.rawValue;
        }
        
        return NewsDetailCellRows.Count.rawValue;
    }
    
    /**
     indexPathに応じたセルを返却
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var retCell = UITableViewCell()
        
        
        switch indexPath.row {
            
        case NewsDetailCellRows.Header.rawValue:
           
            let cell:NewsDetailHeaderCell! = tableView.dequeueReusableCellWithIdentifier("NewsDetailHeaderCell", forIndexPath: indexPath) as? NewsDetailHeaderCell
            
            let title = news["title"]
            let public_at:String! = news["public_at"] as? String
            
            //初期化
            cell.titleLabel.text = nil
            cell.dateLabel.text = nil
            
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
            
            retCell = cell
            
        case NewsDetailCellRows.Content.rawValue:
            let cell:NewsDetailContentCell! = tableView.dequeueReusableCellWithIdentifier("NewsDetailContentCell", forIndexPath: indexPath) as? NewsDetailContentCell
            
            let title:String? = news["content"] as? String
            cell.contentTextView.text = title!

            do {
                
                let html:String = self.headerHTML + title! + self.footerHTML
                
                //テキストをUTF-8エンコード
                let encodedData = html.dataUsingEncoding(NSUTF8StringEncoding)!
                
                //表示データのオプションの設定
                let attributedOptions : [String : AnyObject] = [
                    NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, //表示データのドキュメントタイプ
                    NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding, //表示データの文字エンコード
                ]
                
                //文字列の変換処理の実装（try 〜 catch構文を使っています。）
                let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
                
                //HTMLとしてUITextViewに表示する
                cell.contentTextView.attributedText = attributedString
                //ここは例外処理
            } catch {
                fatalError("Unhandled error: \(error)")
            }
                
            retCell = cell
            
        case NewsDetailCellRows.Count.rawValue:
            break
        default:
            break
            
        }
        
        return retCell
    }

}
