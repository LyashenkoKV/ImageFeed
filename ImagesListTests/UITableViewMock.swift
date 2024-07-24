//
//  UITableViewMock.swift
//  ImagesListTests
//
//  Created by Konstantin Lyashenko on 17.07.2024.
//
@testable import ImageFeed
import UIKit

final class UITableViewMock: UITableView {
    var performBatchUpdatesCalled = false
    var reloadDataCalled = false
    var dequeueReusableCellReturnValue: UITableViewCell!

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdatesCalled = true
        updates?()
        completion?(true)
    }

    override func reloadData() {
        reloadDataCalled = true
    }

    override func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCellReturnValue
    }
}
