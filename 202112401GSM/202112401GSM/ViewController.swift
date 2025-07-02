//
//  ViewController.swift
//  202112401GSM
//
//  Created by Induk cs5 on 2025/05/28.
//

import UIKit

struct ResData: Codable {
    let items: [ResItem]
}

struct ResItem: Codable {
    let title: String
    let link: String
    let description: String
    let pubDate: String
    
    // 한글 날짜 포맷으로 변환 (pubDate 사용)
    var korDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.dateFormat = "yy년 MM월 dd일 E요일 HH시 mm분"
        
        if let date = inputFormatter.date(from: pubDate) {
            return outputFormatter.string(from: date)
        }
        return pubDate
    }
    
    // HTML 태그 제거 (title용)
    var cleanTitle: String {
        guard let data = title.data(using: .utf8) else { return title }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributed?.string ?? title
    }
    
    // HTML 태그 제거 (description용)
    var cleanDescription: String {
        guard let data = description.data(using: .utf8) else { return description }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributed?.string ?? description
    }
}

// 뷰 컨트롤러
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var resData : ResData?
    
    @IBOutlet weak var table: UITableView!
    
    @IBAction func incomeBtn(_ sender: UIButton) {
        getData(query: "주식")
    }
    @IBAction func shoppingBtn(_ sender: UIButton) {
        getData(query: "쇼핑")
    }
    @IBAction func enterBtn(_ sender: UIButton) {
        getData(query: "연예")
    }
    @IBAction func dayBtn(_ sender: UIButton) {
        getData(query: "시사")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getData()
    }
    func getData(query: String = "주식") {
        // 네이버 API 클라이언트 정보
        let clientId = "clientId"
        // 애플리케이션 등록 시 발급받은 클라이언트 아이디
        let clientSecret = "clientSecret"
        // 애플리케이션 등록 시 발급받은 클라이언트 시크릿
        
        // URL 구성
        let urlString = "https://openapi.naver.com/v1/search/news.json?query="
        let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: "\(urlString)?\(queryString)&sort=sim") else { return }
        
        // URLRequest 설정
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        // URLSession으로 요청
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            let decoder = JSONDecoder()
            // 데이터 처리
            do {
            // JSON 파싱
                let decodedData = try decoder.decode(ResData.self, from: JSONdata)
                self.resData = decodedData
                
                for item in decodedData.items {
                    print("제목: \(item.cleanTitle)")
                    print("링크: \(item.link)")
                    print("설명: \(item.cleanDescription)")
                    print("날짜: \(item.korDate)")
                    print("---")
                }
                // 데이터가 로드되면 테이블을 새로고침 함
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } catch {
                print(error)
            }
        }
        // 요청 실행
        task.resume()
    }
    // 한 섹션에 표시할 행의 개수 : 10개
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
//    // 각 셀의 표시될 내용 정의 : OpenAPI로 받아온 정보 추출 후 표시
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyTableViewCell
        
        guard let mTitle = resData?.items[indexPath.row].cleanTitle else { return UITableViewCell() }
        guard let mDescription = resData?.items[indexPath.row].cleanDescription else { return UITableViewCell() }
        guard let mPubDate = resData?.items[indexPath.row].korDate else { return UITableViewCell() }
        cell.reportTitle.text = "제목: \(mTitle)"
        cell.reportDate.text = "날짜: \(mPubDate)"
        cell.reportOverview.text = "\(mDescription)"
        return cell
    }
//    // 표시된 각 셀 선택 시 실행될 작업
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // print(indexPath.description) // 개발자용 확인 구문
//    }
    // 표시될 섹션의 개수 : 1개
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // 표시될 테이블 상단 제목 지정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "키워드 관련 최근 뉴스 기사 (네이버 제공)"
    }
    // 표시될 테이블 하단 내용 지정
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "made by gsmin"
    }
    // 디테일 뷰로 넘길 정보 정의
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! DetailViewController
        let myIndexPath = table.indexPathForSelectedRow!
        let row = myIndexPath.row
        dest.newsLink = (resData?.items[row].link)!
        dest.newsTitle = (resData?.items[row].cleanTitle)!
    }

}

