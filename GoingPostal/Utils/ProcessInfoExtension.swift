//
//  ProcessInfoExtension.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/18.
//

import Foundation

extension ProcessInfo {
    var isRunningTests: Bool {
        return environment["XCTestConfigurationFilePath"] != nil
    }
}
