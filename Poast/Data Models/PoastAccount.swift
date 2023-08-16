//
//  Account.swift
//  Poast
//
//  Created by Christopher Head on 7/31/23.
//

import Foundation

struct PoastAccountModel: Hashable {
    let uuid: UUID
    let handle: String
}

extension PoastAccountModel {
    init(accountObject: PoastAccountObject) {
        self.uuid = accountObject.uuid!
        self.handle = accountObject.handle!
    }
}
