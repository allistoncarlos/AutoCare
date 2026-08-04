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
    private var numericBuffer = CarPlayNumericBuffer(kind: .integer)

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
        prepareBuffer(for: .odometer)
        wizardStep = .odometer
        let template = CPListTemplate(title: "Odômetro", sections: makeWizardSections())
        wizardTemplate = template
        try? await interfaceController.pushTemplate(template, animated: true)
    }

    private func prepareBuffer(for step: WizardStep) {
        guard let draft else { return }

        switch step {
        case .odometer:
            numericBuffer = .integer(value: draft.odometer)
        case .totalCost:
            numericBuffer = .currency(value: draft.totalCost)
        case .fuelCost:
            numericBuffer = .currency(value: draft.fuelCost)
        case .confirm:
            break
        }
    }

    private func commitCurrentBuffer() {
        guard var draft else { return }

        switch wizardStep {
        case .odometer:
            draft.applyOdometer(numericBuffer)
        case .totalCost:
            draft.applyTotalCost(numericBuffer)
        case .fuelCost:
            draft.applyFuelCost(numericBuffer)
        case .confirm:
            break
        }

        self.draft = draft
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
        commitCurrentBuffer()
        wizardStep = step
        prepareBuffer(for: step)

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
        case .odometer, .totalCost, .fuelCost:
            return makeKeypadSections(draft: draft)
        case .confirm:
            return makeConfirmSections(draft)
        }
    }

    private func makeKeypadSections(draft: CarPlayFuelDraft) -> [CPListSection] {
        let display = makeDisplayItem(draft: draft)
        let digitItems = (1...9).map { digit -> CPListItem in
            let item = CPListItem(text: "\(digit)", detailText: nil)
            item.handler = { [weak self] _, completion in
                self?.numericBuffer.append(digit: digit)
                self?.refreshWizard()
                completion()
            }
            return item
        }

        let zeroItem = CPListItem(text: "0", detailText: nil)
        zeroItem.handler = { [weak self] _, completion in
            self?.numericBuffer.append(digit: 0)
            self?.refreshWizard()
            completion()
        }

        let deleteItem = CPListItem(
            text: "Apagar",
            detailText: "Remove o último dígito",
            image: UIImage(systemName: "delete.left.fill")
        )
        deleteItem.handler = { [weak self] _, completion in
            self?.numericBuffer.deleteLast()
            self?.refreshWizard()
            completion()
        }

        let clearItem = CPListItem(
            text: "Limpar",
            detailText: "Zera o valor",
            image: UIImage(systemName: "xmark.circle.fill")
        )
        clearItem.handler = { [weak self] _, completion in
            self?.numericBuffer.clear()
            self?.refreshWizard()
            completion()
        }

        let nextItem = makeNextItem()

        return [
            CPListSection(items: [display], header: displayHeader(for: draft), sectionIndexTitle: nil),
            CPListSection(items: digitItems + [zeroItem], header: "Teclado", sectionIndexTitle: nil),
            CPListSection(items: [deleteItem, clearItem], header: "Editar", sectionIndexTitle: nil),
            CPListSection(items: [nextItem], header: nil, sectionIndexTitle: nil)
        ]
    }

    private func displayHeader(for draft: CarPlayFuelDraft) -> String {
        switch wizardStep {
        case .odometer:
            return "\(draft.vehicleName) · anterior \(draft.previousOdometer) km"
        case .totalCost:
            return "Valor total pago"
        case .fuelCost:
            let liters = draftAfterCommittingBuffer().liters.toLeadingZerosString(decimalPlaces: 2) ?? "—"
            return "Preço por litro · ≈ \(liters) L"
        case .confirm:
            return "Resumo"
        }
    }

    private func makeDisplayItem(draft: CarPlayFuelDraft) -> CPListItem {
        let preview = draftAfterCommittingBuffer()
        let text: String
        let detail: String
        let image: String

        switch wizardStep {
        case .odometer:
            text = numericBuffer.isEmpty ? "—" : "\(numericBuffer.displayText) km"
            detail = "Δ \(preview.odometerDifference) km desde o último"
            image = "gauge.with.dots.needle.67percent"
        case .totalCost:
            text = numericBuffer.displayText
            detail = "Digite os centavos (ex.: 25050 = R$ 250,50)"
            image = "brazilianrealsign.circle.fill"
        case .fuelCost:
            text = "\(numericBuffer.displayText) / L"
            let liters = preview.liters.toLeadingZerosString(decimalPlaces: 2) ?? "—"
            detail = "≈ \(liters) L · digite centavos (ex.: 599 = R$ 5,99)"
            image = "drop.fill"
        case .confirm:
            text = ""
            detail = ""
            image = "checkmark"
        }

        let item = CPListItem(text: text, detailText: detail, image: UIImage(systemName: image))
        item.isEnabled = false
        return item
    }

    private func makeNextItem() -> CPListItem {
        switch wizardStep {
        case .odometer:
            let item = CPListItem(
                text: "Continuar",
                detailText: "Definir valor pago",
                image: UIImage(systemName: "chevron.right.circle.fill")
            )
            item.isEnabled = numericBuffer.integerValue != nil
            item.handler = { [weak self] _, completion in
                self?.advanceWizard(to: .totalCost)
                completion()
            }
            return item
        case .totalCost:
            let item = CPListItem(
                text: "Continuar",
                detailText: "Definir preço por litro",
                image: UIImage(systemName: "chevron.right.circle.fill")
            )
            item.isEnabled = (numericBuffer.decimalValue ?? 0) > 0
            item.handler = { [weak self] _, completion in
                self?.advanceWizard(to: .fuelCost)
                completion()
            }
            return item
        case .fuelCost:
            let item = CPListItem(
                text: "Revisar e salvar",
                detailText: "Confirmar abastecimento",
                image: UIImage(systemName: "checkmark.circle.fill")
            )
            item.isEnabled = (numericBuffer.decimalValue ?? 0) > 0
            item.handler = { [weak self] _, completion in
                self?.advanceWizard(to: .confirm)
                completion()
            }
            return item
        case .confirm:
            return CPListItem(text: "Continuar", detailText: nil)
        }
    }

    /// Preview do draft com o buffer atual aplicado, sem mutar o estado persistido do passo.
    private func draftAfterCommittingBuffer() -> CarPlayFuelDraft {
        guard var draft else {
            return CarPlayFuelDraft(
                vehicleId: "",
                vehicleName: "",
                previousOdometer: 0,
                odometer: 0,
                totalCost: 0,
                fuelCost: 0
            )
        }

        switch wizardStep {
        case .odometer:
            draft.applyOdometer(numericBuffer)
        case .totalCost:
            draft.applyTotalCost(numericBuffer)
        case .fuelCost:
            draft.applyFuelCost(numericBuffer)
        case .confirm:
            break
        }

        return draft
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
