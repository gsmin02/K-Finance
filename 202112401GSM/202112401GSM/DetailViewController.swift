//
//  DetailViewController.swift
//  202112401GSM
//
//  Created by ss on 6/3/25.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var newsTitle = ""
    var newsLink = ""

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = newsTitle
        let urlString = newsLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    

}
