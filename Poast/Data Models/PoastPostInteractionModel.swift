//
//  PoastPostInteractionModel.swift
//  Poast
//
//  Created by Christopher Head on 10/9/24.
//

import Foundation
import SwiftData

@Model
class PoastPostInteractionModel {
    @Attribute(.unique)
    var postId: UUID
    @Relationship(deleteRule: .cascade)
    var like: PoastPostLikeModel?
    @Relationship(deleteRule: .cascade)
    var repost: PoastPostRepostModel?

    init(postId: UUID, like: PoastPostLikeModel? = nil, repost: PoastPostRepostModel? = nil) {
        self.postId = postId
        self.like = like
        self.repost = repost
    }
}
