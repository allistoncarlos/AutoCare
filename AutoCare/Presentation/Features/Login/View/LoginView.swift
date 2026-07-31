//
//  LoginView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 19/02/24.
//

import SwiftData
import SwiftUI
import TTProgressHUD

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var isLoading = false

    @ObservedObject var viewModel: LoginViewModel
    @Environment(\.colorScheme) private var colorScheme

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BrandTheme.Spacing.xl) {
                    Spacer(minLength: BrandTheme.Spacing.xxl)

                    BrandAppHeader(
                        appName: "AutoCare",
                        tagline: "Controle abastecimentos e manutenção do seu veículo."
                    )

                    VStack(spacing: BrandTheme.Spacing.md) {
                        BrandSectionHeader(title: "Acesso", accent: BrandTheme.Colors.violetSoft)

                        BrandCard {
                            VStack(spacing: BrandTheme.Spacing.md) {
                                VStack(alignment: .leading, spacing: BrandTheme.Spacing.xs) {
                                    Text("Usuário")
                                        .font(BrandTheme.Typography.caption(12))
                                        .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                                    BrandTextField(placeholder: "Digite seu usuário", text: $username)
                                }

                                VStack(alignment: .leading, spacing: BrandTheme.Spacing.xs) {
                                    Text("Senha")
                                        .font(BrandTheme.Typography.caption(12))
                                        .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                                    BrandTextField(
                                        placeholder: "Digite sua senha",
                                        text: $password,
                                        isSecure: true
                                    )
                                }
                            }
                        }

                        Button("Entrar") {
                            Task {
                                await viewModel.login(username: username, password: password)
                            }
                        }
                        .disabled(username.isEmpty || password.isEmpty || viewModel.state == .loading)
                        .buttonStyle(MainButtonStyle())
                    }

                    Spacer(minLength: BrandTheme.Spacing.lg)

                    SignatureBadge()
                        .padding(.bottom, BrandTheme.Spacing.lg)
                }
                .padding(.horizontal, BrandTheme.Spacing.lg)
            }
            .brandBackground()
            .overlay(
                TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
            )
            .onChange(of: viewModel.state) { _, newState in
                isLoading = newState == .loading
            }
        }
        .tint(BrandTheme.Colors.violetCore)
        .overlay {
            if case let LoginState.error(error) = viewModel.state {
                alertView(error)
            }
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
        .modelContainer(SwiftDataManager.shared.previewModelContainer)
        .preferredColorScheme(.dark)
}
