import Foundation

@Observable
final class PluginEngine {
    private let plugins: [String: any SearchPlugin]

    init() {
        var map: [String: any SearchPlugin] = [:]
        let registered: [any SearchPlugin] = [BusSearchPlugin(), FlightSearchPlugin()]
        for plugin in registered {
            map[plugin.pluginType] = plugin
        }
        self.plugins = map
    }

    func plugin(for pluginType: String) -> (any SearchPlugin)? {
        plugins[pluginType]
    }
}
