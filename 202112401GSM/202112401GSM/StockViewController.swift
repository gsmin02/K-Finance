//
//  StockViewController.swift
//  202112401GSM
//
//  Created by ss on 6/4/25.
//

import UIKit
import WebKit

class StockViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let urlString = "https://m.stock.naver.com/domestic"
        guard let url = URL(string:urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

}
