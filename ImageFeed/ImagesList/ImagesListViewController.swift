//
//  ViewController.swift
//  ImageFeed
//
//  Created by Konstantin Lyashenko on 06.05.2024.
//

import UIKit

class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ImageListCell.self, forCellReuseIdentifier: "cell")
    }

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ImageListCell
        cell.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        return cell
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
