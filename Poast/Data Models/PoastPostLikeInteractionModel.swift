//
//  PoastPostInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/9/24.
//

import Foundation
import SwiftData

@Model
class PoastPostLikeInteractionModel {
    @Attribute(.unique)
    var postUri: String
    var interaction: PoastPostLikeModel

    init(postUri: String, interaction: PoastPostLikeModel) {
        self.postUri = postUri
        self.interaction = interaction
    }
}
