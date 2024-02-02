//
//  PoastTimelineView.swift
//  Poast
//
//  Created by Christopher Head on 9/24/23.
//

import SwiftUI

struct PoastTimelineView: View {
    let timelineViewModel: PoastTimelineViewModeling

    @EnvironmentObject var session: PoastSessionObject
    
    @State var timeline: PoastTimelineModel?
    @State var showingComposerView: Bool = false

    var body: some View {
        List(self.timeline?.posts ?? []) { post in
            if let parent = post.parent {
                switch(parent) {
                case .post(let parentPost):
                    PoastParentPostView(postViewModel: PoastPostViewModel(), post: parentPost)

                case .notFound(_):
                    Text("Post not found")

                case .blocked(_, _):
                    Text("Blocked post")
                }
            }
            
            PoastPostView(postViewModel: PoastPostViewModel(), post: post)
                .environmentObject(session)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {

                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Poast")
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.showingComposerView = true
                } label: {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $showingComposerView) {
                    EmptyView()
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            Task {
                switch(await self.timelineViewModel.getTimeline(session: self.session)) {
                case .success(let timeline):
                    self.timeline = timeline

                case .failure(_):
                    break
                }
            }
        }
    }
}

#Preview {
    let managedObjectContext = PersistenceController.preview.container.viewContext

    let session = PoastSessionObject(context: managedObjectContext)

    session.created = Date()
    session.accountUUID = UUID()
    session.did = ""

    return PoastTimelineView(timelineViewModel: PoastTimelinePreviewViewModel())
        .environmentObject(session)
}
