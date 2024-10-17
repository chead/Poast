//
//  PoastUser.swift
//  Poast
//
//  Created by Christopher Head on 10/16/24.
//

import SwiftUI

class PoastUser: ObservableObject {
    @Published var active: Bool
    @Published var session: PoastSessionModel?

    init(active: Bool = true, session: PoastSessionModel? = nil) {
        self.active = active
        self.session = session
    }
}
