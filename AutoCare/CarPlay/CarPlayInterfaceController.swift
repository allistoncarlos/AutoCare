//
//  CarPlayInterfaceController.swift
//  AutoCare
//

#if canImport(CarPlay)
import CarPlay
import Foundation

/// Controla os templates CarPlay: home, wizard de abastecimento e recentes.
@MainActor
final class CarPlayInterfaceController: NSObject {
    private enum WizardStep {
        case odometer
        case totalCost
        case fuelCost
        case confirm
    }

    private let interfaceController: CPInterfaceController
    private let service = CarPlayFuelService()

    private var vehicles: [Vehicle] = []
    private var selectedVehicle: Vehicle?
    private var draft: CarPlayFuelDraft?
    private var recentMileages: [VehicleMileage] = []
    private var wizardTemplate: CPListTemplate?
    private var wizardStep: WizardStep = .odometer

    init(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        super.init()
    }

    func start() {
        Task { await reloadAndShowRoot() }
    }

    // MARK: - Root

    private func reloadAndShowRoot() async {
        draft = nil
        wizardTemplate = nil

        guard service.isAuthenticated else {
            try? await interfaceController.setRootTemplate(makeLoginRequiredTemplate(), animated: true)
            return
        }

        vehicles = await service.fetchVehicles()
        selectedVehicle = service.defaultVehicle(from: vehicles)

        guard let selectedVehicle else {
            try? await interfaceController.setRootTemplate(makeEmptyVehiclesTemplate(), animated: true)
            return
        }

        recentMileages = await service.recentMileages(for: selectedVehicle)
        try? await interfaceController.setRootTemplate(makeTabBarTemplate(for: selectedVehicle), animated: true)
    }

    private func makeTabBarTemplate(for vehicle: Vehicle) -> CPTabBarTemplate {
        CPTabBarTemplate(templates: [makeHomeTemplate(for: vehicle), makeRecentTemplate(for: vehicle)])
    }

    private func makeHomeTemplate(for vehicle: Vehicle) -> CPListTemplate {
        var sections: [CPListSection] = []

        let registerItem = CPListItem(
            text: "Novo abastecimento",
            detailText: vehicle.name,
            image: UIImage(systemName: "fuelpump.fill")
        )
        registerItem.handler = { [weak self] _, completion in
            Task { @MainActor in
                await self?.beginFuelEntry(for: vehicle)
                completion()
            }
        }
        sections.append(CPListSection(items: [registerItem], header: "Abastecimento", sectionIndexTitle: nil))

        if vehicles.count > 1 {
            let switchItem = CPListItem(
                text: "Trocar veículo",
                detailText: "Atual: \(vehicle.name)",
                image: UIImage(systemName: "car.fill")
            )
            switchItem.handler = { [weak self] _, completion in
                Task { @MainActor in
                    await self?.showVehiclePicker()
                    completion()
                }
            }
            sections.append(CPListSection(items: [switchItem], header: "Veículo", sectionIndexTitle: nil))
        }

        let lastOdometer = recentMileages.first?.odometer ?? vehicle.odometer
        let summaryItem = CPListItem(
            text: "Odômetro atual",
            detailText: "\(lastOdometer) km",
            image: UIImage(systemName: "gauge.with.dots.needle.67percent")
        )
        summaryItem.isEnabled = false
        sections.append(CPListSection(items: [summaryItem], header: "Resumo", sectionIndexTitle: nil))

        let template = CPListTemplate(title: "AutoCare", sections: sections)
        template.tabImage = UIImage(systemName: "house.fill")
        template.tabTitle = "Início"
        return template
    }

    private func makeRecentTemplate(for vehicle: Vehicle) -> CPListTemplate {
        let items: [CPListItem]
        if recentMileages.isEmpty {
            let empty = CPListItem(
                text: "Nenhum abastecimento",
                detailText: "Registre o primeiro pela aba Início"
            )
            empty.isEnabled = false
            items = [empty]
        } else {
            items = recentMileages.map { mileage in
                let liters = mileage.liters.toLeadingZerosString(decimalPlaces: 1) ?? "—"
                let cost = mileage.totalCost.toCurrencyString() ?? "—"
                let item = CPListItem(
                    text: "\(liters) L · \(cost)",
                    detailText: "\(mileage.odometer) km · \(mileage.date.toFormattedString(dateFormat: AutoCareApp.dateFormat))",
                    image: UIImage(systemName: "drop.fill")
                )
                item.isEnabled = false
                return item
            }
        }

        let template = CPListTemplate(
            title: "Recentes",
            sections: [CPListSection(items: items, header: vehicle.name, sectionIndexTitle: nil)]
        )
        template.tabImage = UIImage(systemName: "clock.fill")
        template.tabTitle = "Recentes"
        return template
    }

    private func makeLoginRequiredTemplate() -> CPListTemplate {
        let item = CPListItem(
            text: "Faça login no iPhone",
            detailText: "Abra o AutoCare e entre na sua conta para registrar abastecimentos no CarPlay.",
            image: UIImage(systemName: "person.crop.circle.badge.exclamationmark")
        )
        item.isEnabled = false
        return CPListTemplate(title: "AutoCare", sections: [CPListSection(items: [item])])
    }

    private func makeEmptyVehiclesTemplate() -> CPListTemplate {
        let item = CPListItem(
            text: "Cadastre um veículo",
            detailText: "Adicione um veículo no app do iPhone para começar.",
            image: UIImage(systemName: "car.side")
        )
        item.isEnabled = false
        return CPListTemplate(title: "AutoCare", sections: [CPListSection(items: [item])])
    }

    // MARK: - Vehicle picker

    private func showVehiclePicker() async {
        let items = vehicles.map { vehicle -> CPListItem in
            let isSelected = vehicle.clientId == selectedVehicle?.clientId
            let item = CPListItem(
                text: vehicle.name,
                detailText: "\(vehicle.brand) \(vehicle.model)",
                image: UIImage(systemName: isSelected ? "checkmark.circle.fill" : "car.fill")
            )
            item.handler = { [weak self] _, completion in
                Task { @MainActor in
                    await self?.selectVehicle(vehicle)
                    completion()
                }
            }
            return item
        }

        let template = CPListTemplate(
            title: "Veículos",
            sections: [CPListSection(items: items, header: "Selecione", sectionIndexTitle: nil)]
        )
        try? await interfaceController.pushTemplate(template, animated: true)
    }

    private func selectVehicle(_ vehicle: Vehicle) async {
        selectedVehicle = vehicle
        recentMileages = await service.recentMileages(for: vehicle)
        try? await interfaceController.popToRootTemplate(animated: false)
        try? await interfaceController.setRootTemplate(makeTabBarTemplate(for: vehicle), animated: true)
    }

    // MARK: - Fuel entry wizard

    private func beginFuelEntry(for vehicle: Vehicle) async {
        draft = await service.makeDraft(for: vehicle)
        wizardStep = .odometer
        let template = CPListTemplate(title: "Odômetro", sections: makeWizardSections())
        wizardTemplate = template
        try? await interfaceController.pushTemplate(template, animated: true)
    }

    private func refreshWizard(title: String? = nil) {
        guard let wizardTemplate else { return }

        if let title {
            Task { @MainActor in
                let replacement = CPListTemplate(title: title, sections: makeWizardSections())
                self.wizardTemplate = replacement
                try? await interfaceController.popTemplate(animated: false)
                try? await interfaceController.pushTemplate(replacement, animated: true)
            }
            return
        }

        wizardTemplate.updateSections(makeWizardSections())
    }

    private func advanceWizard(to step: WizardStep) {
        wizardStep = step
        let title: String
        switch step {
        case .odometer: title = "Odômetro"
        case .totalCost: title = "Valor total"
        case .fuelCost: title = "Preço / L"
        case .confirm: title = "Confirmar"
        }
        refreshWizard(title: title)
    }

    private func makeWizardSections() -> [CPListSection] {
        guard let draft else { return [] }

        switch wizardStep {
        case .odometer:
            return makeOdometerSections(draft)
        case .totalCost:
            return makeTotalCostSections(draft)
        case .fuelCost:
            return makeFuelCostSections(draft)
        case .confirm:
            return makeConfirmSections(draft)
        }
    }

    private func makeOdometerSections(_ draft: CarPlayFuelDraft) -> [CPListSection] {
        let valueItem = CPListItem(
            text: "\(draft.odometer) km",
            detailText: "Anterior: \(draft.previousOdometer) km · Δ \(draft.odometerDifference) km",
            image: UIImage(systemName: "gauge.with.dots.needle.67percent")
        )
        valueItem.isEnabled = false

        let adjustments: [(String, Int)] = [
            ("+1 km", 1), ("+10 km", 10), ("+50 km", 50), ("+100 km", 100),
            ("−1 km", -1), ("−10 km", -10), ("−50 km", -50)
        ]

        let adjustItems = adjustments.map { title, delta -> CPListItem in
            let item = CPListItem(text: title, detailText: nil)
            item.handler = { [weak self] _, completion in
                self?.draft?.adjustOdometer(by: delta)
                self?.refreshWizard()
                completion()
            }
            return item
        }

        let nextItem = CPListItem(
            text: "Continuar",
            detailText: "Definir valor pago",
            image: UIImage(systemName: "chevron.right.circle.fill")
        )
        nextItem.handler = { [weak self] _, completion in
            self?.advanceWizard(to: .totalCost)
            completion()
        }

        return [
            CPListSection(items: [valueItem], header: draft.vehicleName, sectionIndexTitle: nil),
            CPListSection(items: adjustItems, header: "Ajustar", sectionIndexTitle: nil),
            CPListSection(items: [nextItem], header: nil, sectionIndexTitle: nil)
        ]
    }

    private func makeTotalCostSections(_ draft: CarPlayFuelDraft) -> [CPListSection] {
        let valueItem = CPListItem(
            text: draft.totalCost.toCurrencyString() ?? "R$ 0,00",
            detailText: "Valor total do abastecimento",
            image: UIImage(systemName: "brazilianrealsign.circle.fill")
        )
        valueItem.isEnabled = false

        let adjustments: [(String, Decimal)] = [
            ("+ R$ 1", 1), ("+ R$ 10", 10), ("+ R$ 50", 50), ("+ R$ 100", 100),
            ("− R$ 1", -1), ("− R$ 10", -10), ("− R$ 50", -50)
        ]

        let adjustItems = adjustments.map { title, delta -> CPListItem in
            let item = CPListItem(text: title, detailText: nil)
            item.handler = { [weak self] _, completion in
                self?.draft?.adjustTotalCost(by: delta)
                self?.refreshWizard()
                completion()
            }
            return item
        }

        let nextItem = CPListItem(
            text: "Continuar",
            detailText: "Definir preço por litro",
            image: UIImage(systemName: "chevron.right.circle.fill")
        )
        nextItem.handler = { [weak self] _, completion in
            self?.advanceWizard(to: .fuelCost)
            completion()
        }

        return [
            CPListSection(items: [valueItem], header: "Custo", sectionIndexTitle: nil),
            CPListSection(items: adjustItems, header: "Ajustar", sectionIndexTitle: nil),
            CPListSection(items: [nextItem], header: nil, sectionIndexTitle: nil)
        ]
    }

    private func makeFuelCostSections(_ draft: CarPlayFuelDraft) -> [CPListSection] {
        let litersText = draft.liters.toLeadingZerosString(decimalPlaces: 2) ?? "0"
        let valueItem = CPListItem(
            text: "\(draft.fuelCost.toCurrencyString() ?? "R$ 0,00") / L",
            detailText: "≈ \(litersText) L (tanque completo)",
            image: UIImage(systemName: "drop.fill")
        )
        valueItem.isEnabled = false

        let adjustments: [(String, Decimal)] = [
            ("+ R$ 0,01", Decimal(string: "0.01") ?? 0.01),
            ("+ R$ 0,10", Decimal(string: "0.10") ?? 0.10),
            ("+ R$ 0,50", Decimal(string: "0.50") ?? 0.50),
            ("− R$ 0,01", Decimal(string: "-0.01") ?? -0.01),
            ("− R$ 0,10", Decimal(string: "-0.10") ?? -0.10),
            ("− R$ 0,50", Decimal(string: "-0.50") ?? -0.50)
        ]

        let adjustItems = adjustments.map { title, delta -> CPListItem in
            let item = CPListItem(text: title, detailText: nil)
            item.handler = { [weak self] _, completion in
                self?.draft?.adjustFuelCost(by: delta)
                self?.refreshWizard()
                completion()
            }
            return item
        }

        let nextItem = CPListItem(
            text: "Revisar e salvar",
            detailText: "Confirmar abastecimento",
            image: UIImage(systemName: "checkmark.circle.fill")
        )
        nextItem.handler = { [weak self] _, completion in
            self?.advanceWizard(to: .confirm)
            completion()
        }

        return [
            CPListSection(items: [valueItem], header: "Combustível", sectionIndexTitle: nil),
            CPListSection(items: adjustItems, header: "Ajustar", sectionIndexTitle: nil),
            CPListSection(items: [nextItem], header: nil, sectionIndexTitle: nil)
        ]
    }

    private func makeConfirmSections(_ draft: CarPlayFuelDraft) -> [CPListSection] {
        let liters = draft.liters.toLeadingZerosString(decimalPlaces: 2) ?? "—"
        let kmL = draft.calculatedMileage.toLeadingZerosString(decimalPlaces: 2) ?? "—"
        let total = draft.totalCost.toCurrencyString() ?? "—"
        let perLiter = draft.fuelCost.toCurrencyString() ?? "—"

        let summaryItems: [CPListItem] = [
            lockedItem(text: draft.vehicleName, detail: "Veículo", image: "car.fill"),
            lockedItem(
                text: "\(draft.odometer) km",
                detail: "+\(draft.odometerDifference) km desde o último",
                image: "gauge.with.dots.needle.67percent"
            ),
            lockedItem(
                text: total,
                detail: "\(perLiter)/L · \(liters) L",
                image: "brazilianrealsign.circle.fill"
            ),
            lockedItem(text: "\(kmL) km/L", detail: "Consumo estimado", image: "leaf.fill")
        ]

        let saveItem = CPListItem(
            text: "Salvar abastecimento",
            detailText: draft.isValid ? "Grava no app e sincroniza" : "Ajuste odômetro e valores",
            image: UIImage(systemName: "square.and.arrow.down.fill")
        )
        saveItem.isEnabled = draft.isValid
        saveItem.handler = { [weak self] _, completion in
            Task { @MainActor in
                await self?.saveDraft()
                completion()
            }
        }

        return [
            CPListSection(items: summaryItems, header: "Resumo", sectionIndexTitle: nil),
            CPListSection(items: [saveItem], header: nil, sectionIndexTitle: nil)
        ]
    }

    private func lockedItem(text: String, detail: String, image: String) -> CPListItem {
        let item = CPListItem(text: text, detailText: detail, image: UIImage(systemName: image))
        item.isEnabled = false
        return item
    }

    private func saveDraft() async {
        guard let draft else { return }

        let saved = await service.save(draft: draft)

        if saved != nil {
            await showSaveSuccessAndReturnHome()
        } else {
            await showSaveError()
        }
    }

    private func showSaveSuccessAndReturnHome() async {
        let ok = CPAlertAction(title: "OK", style: .default) { [weak self] _ in
            Task { @MainActor in
                try? await self?.interfaceController.dismissTemplate(animated: true)
                await self?.reloadAndShowRoot()
            }
        }
        let alert = CPAlertTemplate(titleVariants: ["Abastecimento salvo"], actions: [ok])
        try? await interfaceController.presentTemplate(alert, animated: true)
    }

    private func showSaveError() async {
        let ok = CPAlertAction(title: "OK", style: .cancel) { [weak self] _ in
            Task { @MainActor in
                try? await self?.interfaceController.dismissTemplate(animated: true)
            }
        }
        let alert = CPAlertTemplate(titleVariants: ["Não foi possível salvar"], actions: [ok])
        try? await interfaceController.presentTemplate(alert, animated: true)
    }
}
#endif
