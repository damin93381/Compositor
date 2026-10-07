import AppKit
import Testing
@testable import Compositor

@MainActor
struct LocalizationTests {
    @Test func chineseResourcesCoverCoreWorkflow() throws {
        let path = try #require(Bundle.main.path(forResource: "zh-Hans", ofType: "lproj"))
        let chinese = try #require(Bundle(path: path))
        #expect(chinese.localizedString(forKey: "New Canvas…", value: nil, table: nil) == "新建画布…")
        #expect(chinese.localizedString(forKey: "Save", value: nil, table: nil) == "保存")
        #expect(chinese.localizedString(forKey: "Multiply", value: nil, table: nil) == "正片叠底")
    }

    @Test func translatingAMenuTitleDoesNotChangeItsBlendMode() throws {
        let session = EditorSession()
        session.createDocument(width: 40, height: 20, emptyLayer: true)
        let coordinator = BlendModePicker.Coordinator(session: session)
        let button = NSPopUpButton(frame: .zero, pullsDown: false)
        button.addItem(withTitle: "正片叠底")
        button.lastItem?.representedObject = LayerBlendMode.multiply
        coordinator.menuWillOpen(try #require(button.menu))
        coordinator.choose(button)
        #expect(session.activeLayer?.blendMode == .multiply)
    }

    @Test func savedBlendModeAndShortcutKeysRemainEnglish() throws {
        let encoded = try JSONEncoder().encode(LayerBlendMode.multiply)
        #expect(String(decoding: encoded, as: UTF8.self) == "\"Multiply\"")
        let save = try #require(ShortcutDefinition.all.first { $0.title == "Save" && $0.isMenu })
        #expect(save.id == "Menus:Save")
    }

    @Test func chineseTextAndNamesSurviveSavingAndExport() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("CompositorLocalization-\(UUID())")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: folder) }
        let session = EditorSession()
        session.createDocument(width: 640, height: 480, emptyLayer: true)
        session.beginText(at: CGPoint(x: 40, y: 80))
        var draft = try #require(session.textDraft)
        draft.style.content = "中文版测试\n图层与蒙版"
        #expect(session.applyText(draft))
        session.renameLayer(try #require(session.activeLayerID), to: "中文文字图层")
        let project = folder.appendingPathComponent("中文项目.comp")
        try await ProjectStore.shared.save(try #require(session.projectSnapshot()), to: project)
        let loaded = try await ProjectStore.shared.load(from: project)
        let reopened = EditorSession()
        reopened.installProject(loaded, from: project)
        #expect(reopened.activeLayer?.name == "中文文字图层")
        #expect(reopened.activeLayer?.liveText?.style.content == draft.style.content)
        #expect(loaded.manifest.version == 11)
        let png = folder.appendingPathComponent("中文导出.png")
        try await ImageExporter.shared.exportPNG(try #require(reopened.projectSnapshot()), to: png)
        let image = try #require(NSImage(contentsOf: png))
        #expect(image.size == CGSize(width: 640, height: 480))
    }
}
