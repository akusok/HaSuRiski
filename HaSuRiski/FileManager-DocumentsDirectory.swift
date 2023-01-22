//
//  FileManager-DocumentsDirectory.swift
//  HaSuRiski
//
//  Created by Anton Akusok on 22.1.2023.
//

import Foundation

extension FileManager {
    static var documentDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
