//
//  LoginView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 19/02/24.
//

import SwiftUI
import Realm
import TTProgressHUD

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoading = false

    @EnvironmentObject var app: RLMApp
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            if case .success = viewModel.state {
                viewModel.homeView()
            } else {
                NavigationView {
                    Form {
                        TextField("E-mail", text: $email)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password) {
                            Task {
                                await viewModel.login(email: email, password: password)
                            }
                        }

                        Section(
                            footer:
                            Button("Login") {
                                Task {
                                    await viewModel.login(email: email, password: password)
                                }
                            }
                            .disabled(email.isEmpty || password.isEmpty || viewModel.state == .loading)
                            .buttonStyle(MainButtonStyle())
                        ) {
                            EmptyView()
                        }
                    }
                    .overlay(
                        TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
                    )
                    .onChange(of: viewModel.state, { _, newState in
                        isLoading = newState == .loading
                    })
                    .navigationTitle("Login")
                }
                .navigationViewStyle(.stack)

                if case let LoginState.error(error) = viewModel.state {
                    alertView(error)
                }
            }
        }
        .task {
            await viewModel.setup(app: app)
        }
    }

    func alertView(_ error: LoginError) -> AnyView {
        var errorMessage = ""

        switch error {
        case .invalidUsernameOrPassword:
            errorMessage = "Usuário ou senha inválidos"
        }

        return AnyView(Text("")
            .alert(isPresented: .constant(true)) {
                Alert(
                    title: Text("AutoCare"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"), action: { viewModel.state = .idle })
                )
            }
        )
    }

}

#Preview {
    LoginView(viewModel: LoginViewModel())
}
