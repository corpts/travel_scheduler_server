import 'package:aqueduct/managed_auth.dart';

import 'auth/controller.dart';
import 'auth/user.dart';
import 'travel_scheduler_server.dart';

class TravelSchedulerServerChannel extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final conf = DatabaseConfiguration.fromFile(File('./config.yaml'));
    final psc = PostgreSQLPersistentStore.fromConnectionInfo(
        conf.username, conf.password, conf.host, conf.port, conf.databaseName);

    context = ManagedContext(dataModel, psc);

    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  @override
  Controller get entryPoint {
    final router = Router();
    router
        .route('/auth/token')
        .link(() => AuthController(authServer));
    router
      .route('/signup')
      .link(() => RegisterController(context, authServer));

    return router;
  }
}