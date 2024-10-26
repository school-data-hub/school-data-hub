import 'package:eventflux/eventflux.dart';
import 'package:schuldaten_hub/common/services/env_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/services/session_manager.dart';
import 'package:schuldaten_hub/common/utils/logger.dart';

class EventFluxService {
  static final EventFluxService _instance = EventFluxService._internal();

  factory EventFluxService() {
    return _instance;
  }
  EventFluxService._internal() {
    _init();
  }

  final sessionManager = locator<SessionManager>();
  final EnvManager envManager = locator<EnvManager>();
  void _init() {
    EventFlux.instance.connect(
      EventFluxConnectionType.get,
      '${envManager.env.value.serverUrl}/listen',
      files: [
        /// Optional, If you want to send multipart files with the request
      ],
      multipartRequest: true,
      onSuccessCallback: (EventFluxResponse? response) {
        response?.stream?.listen((data) {
          logger.d('EventFlux event: ${data.event}, data: ${data.data}');
        });
      },
      onError: (oops) {
        logger.e('EventFlux error message: ${oops.message}');
        logger.e('EventFlux error reason phrase: ${oops.reasonPhrase}');
        // Oops! Time to handle those little hiccups.
        // You can also choose to disconnect here
      },
      autoReconnect: true,
      reconnectConfig: ReconnectConfig(
        mode: ReconnectMode.linear,
        interval: const Duration(seconds: 5),
      ),
    );
    logger.d('EventFluxService initialized!');
  }
}
