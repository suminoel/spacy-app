//
//  ViewController.swift
//  spacy
//
//  Created by 田中邦明 on 2019/05/05.
//  Copyright © 2019年 田中邦明. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var reloadBtn: UIBarButtonItem!

    @IBAction func backPage(_ sender: UIBarButtonItem) {
        self.webView.goBack()
    }

    @IBAction func reloadPage(_ sender: UIBarButtonItem) {
        self.webView.reload()
    }

    let homeUrl = "localhost"

    // Viewを作成する
    override func loadView() {

        super.loadView()
        let viewConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: viewConfiguration)
        self.view = webView

        webView.uiDelegate = self
        webView.navigationDelegate = self

        // スワイプで戻る、進むを有効にする
        webView.allowsBackForwardNavigationGestures = true

        // リロードのイベントを受け取る
        self.webView.scrollView.bounces = true
        let refreshControl = UIRefreshControl()
        self.webView.scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ViewController.refreshWebView(sender:)), for: .valueChanged)
    }

    // Webページを読み込む
    override func viewDidLoad() {
        super.viewDidLoad()

        // 最初はBackボタンを非表示
        self.backBtn.isEnabled = false
        self.backBtn.tintColor = UIColor.clear

        // 表示するWebページのURLRequestを作る
        if let url = NSURL(string: homeUrl) {
            let request = NSURLRequest(url: url as URL)
            let userAgentStr = "Spacy App WebView"

            // UA偽装
            webView.customUserAgent = userAgentStr

            // Webページを読み込む
            webView.load(request as URLRequest)
        }

        let statusBarBackground = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIApplication.shared.statusBarFrame.size.width, height: UIApplication.shared.statusBarFrame.size.height))
        statusBarBackground.backgroundColor = .white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // ページをリロードするメソッド
    @objc func refreshWebView(sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
}

// target=”_blank”が設定されたリンク先を開けるようにする
extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let url = URL(string: navigationAction.request.description)
            if let url = url{
                let vc = SFSafariViewController(url: url)
                present(vc, animated: true, completion: nil)
            }
            // webView.load(navigationAction.request)
        }
        return nil
    }

    //読み込み完了時に呼ばれる
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 現在のURL取得
        let activeUrl: URL? = self.webView.url
        let url = activeUrl?.absoluteString

        // SpacyのURLでなければBackボタンを表示
        if url!.contains(homeUrl) == false {
            self.backBtn.isEnabled = true
            self.backBtn.tintColor = UIColor.init(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        }

        //タイトルの取得
        let title = self.webView?.title
        //ナビゲーションにタイトルを設定
        navigationItem.title = title
    }
}
