//
//  isPlayingExtension.swift
//  Soundlytude
//
//  Created by DJ bon26 on 10/13/22.
//
import Foundation
import AVFoundation
import SwiftUI
import UIKit

extension AVPlayer {
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension Image {
  init?(base64String: String) {
    guard let data = Data(base64Encoded: base64String) else { return nil }
    #if os(macOS)
    guard let image = NSImage(data: data) else { return nil }
    self.init(nsImage: image)
    #elseif os(iOS)
    guard let image = UIImage(data: data) else { return nil }
    self.init(uiImage: image)
    #else
    return nil
    #endif
  }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension View {
/// Layers the given views behind this ``TextEditor``.
    func textEditorBackground<V>(@ViewBuilder _ content: () -> V) -> some View where V : View {
        self
            .onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
            .background(content())
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

public extension View {
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        modifier(FirstAppear(action: action))
    }
}

public struct FirstAppear: ViewModifier {
    let action: () -> ()
    
    // Use this to only fire your block one time
    @State public var hasAppeared = false
    
    public func body(content: Content) -> some View {
        // And then, track it here
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}

extension String {
func slice(from: String, to: String) -> String? {
    
    return (range(of: from)?.upperBound).flatMap { substringFrom in
        (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
            String(self[substringFrom..<substringTo])
        }
    }
}
}


// for cotext Menu
struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var navigate: () -> Void
    init(content: Content, preview: Preview, menu: UIMenu, navigate: @escaping () -> Void) {
        self.content = content
        self.preview = preview
        self.menu = menu
        self.navigate = navigate
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(_ parent: ContextMenuHelper) {
            self.parent = parent
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil) {
                let previewController = UIHostingController(rootView: self.parent.preview)
                return previewController
            } actionProvider: { items in
                return self.parent.menu
            }
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            parent.navigate()
        }
    }
}

extension View {
    func contextMenu<Preview: View>(navigate: @escaping () -> Void = {}, @ViewBuilder preview: @escaping () -> Preview, menu: @escaping () -> UIMenu) -> some View {
        return CustomContextMenu(navigate: navigate, content: {self}, preview: preview, menu: menu)
    }
}

struct CustomContextMenu<Content: View, Preview: View>: View {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var navigate: () -> Void
    init(navigate: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content, @ViewBuilder preview: @escaping () -> Preview, menu: @escaping () -> UIMenu) {
        self.content = content()
        self.preview = preview()
        self.menu = menu()
        self.navigate = navigate
    }
    var body: some View {
        ZStack {
            content
                .overlay(ContextMenuHelper(content: content, preview: preview, menu: menu, navigate: navigate))
        }
    }
}

//end of context menu

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

extension ViewBuilder {

    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13, _ c14: C14
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13, C14)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View, C14: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13, c14)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13, _ c14: C14, _ c15: C15
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13, C14, C15)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View, C14: View, C15: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13, c14, c15)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13, _ c14: C14, _ c15: C15, _ c16: C16
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13, C14, C15, C16)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View, C14: View, C15: View, C16: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13, c14, c15, c16)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13, _ c14: C14, _ c15: C15, _ c16: C16, _ c17: C17
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13, C14, C15, C16, C17)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View, C14: View, C15: View, C16: View, C17: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13, c14, c15, c16, c17)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13, _ c14: C14, _ c15: C15, _ c16: C16, _ c17: C17, _ c18: C18
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13, C14, C15, C16, C17, C18)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View, C14: View, C15: View, C16: View, C17: View, C18: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13, c14, c15, c16, c17, c18)) }
        ))
    }
    
    public static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11, C12, C13, C14, C15, C16, C17, C18, C19>(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11, _ c12: C12, _ c13: C13, _ c14: C14, _ c15: C15, _ c16: C16, _ c17: C17, _ c18: C18, _ c19: C19
    ) -> TupleView<
        (
            Group<TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>>,
            Group<TupleView<(C10, C11, C12, C13, C14, C15, C16, C17, C18, C19)>>
        )
    >
    where C0: View, C1: View, C2: View, C3: View, C4: View, C5: View, C6: View, C7: View, C8: View, C9: View, C10: View, C11: View, C12: View, C13: View, C14: View, C15: View, C16: View, C17: View, C18: View, C19: View {
        TupleView((
            Group { TupleView((c0, c1, c2, c3, c4, c5, c6, c7, c8, c9)) },
            Group { TupleView((c10, c11, c12, c13, c14, c15, c16, c17, c18, c19)) }
        ))
    }
}
