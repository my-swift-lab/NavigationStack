import SwiftUI

/// The navigation view used to switch content when applying a navigation transition.
///
/// This view works similar to SwiftUI's `NavigationView`.
/// Place it as the view's root and provide the default content to show when no navigation transition has been applied.
/// Use the `NavigationModel` to provide a destination view and transition animation to navigate to.
///
/// - Important:
/// A single instance of the `NavigationModel` has to be injected into the view hierarchy as an environment object:
/// `MyRootView().environmentObject(NavigationModel())`
public struct NavigationStackView<IdentifierType>: View where IdentifierType: Equatable {
	/**
	 Initializes the navigation stack view with a given ID and its default content.

	 - parameter identifier: The navigation stack view's ID.
	 This is the reference ID to use when applying a navigation via the model and targeting this layer of stack.
	 - parameter defaultView: The content view to show when no navigation has been applied.
	 */
	public init<Content>(_ identifier: IdentifierType, @ViewBuilder defaultView: @escaping () -> Content) where Content: View {
		self.identifier = identifier
		self.defaultView = { AnyView(defaultView()) }
	}

	@EnvironmentObject private var model: NavigationStackModel<IdentifierType>

	/// This navigation stack view's ID.
	let identifier: IdentifierType
	/// The navigation stack view's default content to show when no navigation has been applied.
	private let defaultView: AnyViewBuilder

	public var body: some View {
		ZStack {
			if model.isAlternativeViewShowingPrecede(identifier) { // `if-else` and the precede-call are necessary, see Experiment8
				ContentViews(identifier: identifier, defaultView: defaultView)
			} else {
				ContentViews(identifier: identifier, defaultView: defaultView)
			}
		}
	}
}

private struct ContentViews<IdentifierType>: View where IdentifierType: Equatable {
	@EnvironmentObject private var model: NavigationStackModel<IdentifierType>

	/// This navigation stack view's ID.
	let identifier: IdentifierType
	/// The navigation stack view's default content.
	let defaultView: AnyViewBuilder

	var body: some View {
		ZStack {
			if !model.isAlternativeViewShowing(identifier) {
				defaultView().transition(model.defaultViewTransition(identifier)).zIndex(model.defaultViewZIndex(identifier))
			} // No `else`, see Experiment2
			if model.isAlternativeViewShowing(identifier), let alternativeView = model.alternativeView(identifier) {
				alternativeView().transition(model.alternativeViewTransition(identifier)).zIndex(model.alternativeViewZIndex(identifier))
			}
		}
	}
}
