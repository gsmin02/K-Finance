//
//  ExchangeController.swift
//  202112401GSM
//
//  Created by Induk cs5 on 2025/06/03.
//

import UIKit

struct ExcItem: Codable {
    let result: Int
    let cur_unit: String
    let ttb: String
    let tts: String
    let deal_bas_r: String
    let bkpr: String
    let yy_efee_r: String
    let ten_dd_efee_r: String
    let kftc_bkpr: String
    let kftc_deal_bas_r: String
    let cur_nm: String
}

class ExchangeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    
    var excItems: [ExcItem]?
    var excUrl = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=authkey&searchdate="
    private let maxRetries = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        getExcData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 23
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "excCell", for: indexPath) as! ExchangeTableViewCell
        
        guard let mUnit = excItems?[indexPath.row].cur_unit else { return UITableViewCell() }
        cell.ctrCode.text = mUnit
        guard let mNm = excItems?[indexPath.row].cur_nm else { return UITableViewCell() }
        cell.ctrExc.text = "화폐 : \(mNm)"
        guard let mTtb = excItems?[indexPath.row].ttb else { return UITableViewCell() }
        cell.ctrBuy.text = "살 때 : \(mTtb)"
        guard let mTts = excItems?[indexPath.row].tts else { return UITableViewCell() }
        cell.ctrSell.text = "팔 때 : \(mTts)"
        
        return cell
    }

    func makeDate(dateCnt: Int) -> String {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: dateCnt, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: yesterday)
    }
    
    func getExcData(retryCount: Int = 0) {
        guard retryCount < maxRetries else {
            print("최대 재시도 횟수 초과")
            return
        }

        let dateString = makeDate(dateCnt: -retryCount)
        let urlString = "\(excUrl)\(dateString)&data=AP01"
        guard let url = URL(string: urlString) else { return }

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print(error!)
                return
            }
            guard let JSONdata = data else { return }
            let decoder = JSONDecoder()
            do {
                print("do 진입")
                let decodedData = try decoder.decode([ExcItem].self, from: JSONdata)
                print("try 완료")
                if decodedData.isEmpty {
                    print("반환 실패 : Null, 재시도 : \(retryCount + 1)회, \(dateString)")
                    self.getExcData(retryCount: retryCount + 1)
                    return
                }
                self.excItems = decodedData
                print("반환 성공, 재시도 횟수 \(retryCount+1)회, \(dateString)")
                for item in decodedData {
                    print("국가: \(item.cur_nm)")
                }
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            } catch {
                print("catch 발생")
                print("디코딩 실패: \(error), 재시도 : \(retryCount + 1)회, \(dateString)")
                self.getExcData(retryCount: retryCount + 1)
            }
        }
        task.resume()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "국가별 환율 정보 (한국수출입은행 제공)"
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "made by gsmin"
    }
}
