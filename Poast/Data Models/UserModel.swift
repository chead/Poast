//
//  UserModel.swift
//  Poast
//
//  Created by Christopher Head on 10/16/24.
//

import SwiftUI

class UserModel: ObservableObject {
    @Published var active: Bool
    @Published var session: SessionModel?

    init(active: Bool = true, session: SessionModel? = nil) {
        self.active = active
        self.session = session
    }
}
