//
//  PoastLandingView.swift
//  Poast
//
//  Created by Christopher Head on 1/19/24.
//

import SwiftUI

struct PoastLandingView: View {
    let landingViewModel: PoastLandingViewModel

    @State var activeAccountSession: (account: PoastAccountObject, session: PoastSessionObject)? = nil

    var body: some View {
        Group {
            if let activeAccountSession = self.activeAccountSession {
                PoastTabView(account: activeAccountSession.account)
                    .environmentObject(activeAccountSession.session)
            } else {
                PoastAccountsView(accountsViewModel: PoastAccountsViewModel())
            }
        }
        .onAppear() {
            switch(self.landingViewModel.getActiveSession()) {
            case .success(let session):
                guard let session = session else { break }

                switch(self.landingViewModel.getAccount(session: session)) {
                case .success(let account):
                    guard let account = account else { break }

                    self.activeAccountSession = (account: account, session: session)

                case .failure(_):
                    break
                }

            case .failure(_):
                break
            }
        }
    }
}

#Preview {
    PoastLandingView(landingViewModel: PoastLandingViewModel())
}
