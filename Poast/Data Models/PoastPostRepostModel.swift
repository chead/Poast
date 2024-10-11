//
//  PoastPostRepostModel.swift
//  Poast
//
//  Created by Christopher Head on 10/9/24.
//

import Foundation
import SwiftData

@Model
class PoastPostRepostModel {
    var interaction: PoastPostLikeInteractionModel
    var date: Date

    init(interaction: PoastPostLikeInteractionModel, date: Date) {
        self.interaction = interaction
        self.date = date
    }
}
