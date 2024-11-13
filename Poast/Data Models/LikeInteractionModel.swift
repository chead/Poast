//
//  PoastPostInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/9/24.
//

import SwiftData

@Model
final class LikeInteractionModel {
    @Attribute(.unique)
    var postUri: String
    var interaction: LikeModel

    init(postUri: String, interaction: LikeModel) {
        self.postUri = postUri
        self.interaction = interaction
    }
}
