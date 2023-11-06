import Foundation
import GMMapUtility
import Mapbox
import NunavSDKMultiplatform

final class NunavSDKMapLayersControllerBuilder: MapLayerHandlerBuilder {
    private let mapLocationProvider: LocationProvider
    private let navigationSdk: NavigationSdk
    private let routeDetachStateProvider: RouteDetachStateProvider

    init(mapLocationProvider: LocationProvider, navigationSdk: NavigationSdk, routeDetachStateProvider: RouteDetachStateProvider) {
        self.mapLocationProvider = mapLocationProvider
        self.navigationSdk = navigationSdk
        self.routeDetachStateProvider = routeDetachStateProvider
    }

    func mapLayerHandler(for mapView: MGLMapView, withMapTheme mapTheme: MapTheme) -> MGLStyleLayersHandler {
        let mapLayerManager = MapboxMapLayerManager(mapView: mapView)
        return AggregatingMGLStyleLayersHandler(
            mapLayerManager: mapLayerManager,
            layerHandlers: [
                NavigationLayerHandler(
                    mapLayerManager: mapLayerManager,
                    navigationSdk: navigationSdk,
                    mapTheme: mapTheme,
                    routeFeatureCreator: DetachAwareRouteFeatureCreator(
                        navigationSdk: navigationSdk,
                        routeDetachStateProvider: routeDetachStateProvider,
                        detachedRouteFeatureCreator: ColoringRouteFeatureCreator(
                            fillColor: DetachConstants.shared.ROUTE_FILL_COLOR,
                            outlineColor: DetachConstants.shared.ROUTE_OUTLINE_COLOR
                        ),
                        defaultSpeedFeatureCreator: RelativeSpeedRouteFeatureCreator()
                    ),
                    mapLocationProvider: mapLocationProvider,
                    routeDetachStateProvider: routeDetachStateProvider
                ),
                UserLocationLayerHandler(
                    mapLayerManager: mapLayerManager,
                    locationProvider: mapLocationProvider,
                    navigationSdk: navigationSdk,
                    routeDetachStateProvider: routeDetachStateProvider
                )
            ]
        )
    }
}
