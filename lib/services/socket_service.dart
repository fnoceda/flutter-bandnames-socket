import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;
  get serverStatus => this._serverStatus;
  get socket => this._socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    //si no conecta al servidor localhost usar ip de la pc
    _socket = IO.io(
      'http://192.168.0.42:3000',
      {
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );
    _socket.on('connect', (_) {
      print('conectado al socket');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    // socket.onDisconnect((_) => print('disconnect'));
    _socket.on('disconnect', (_) {
      print('desconectado del socket');
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    _socket.on('nuevo-mensaje', (payload) {
      print('nuevo-mensaje del socket => $payload ');

      print('nombre => ${payload['nombre']}');
      print('mensaje => ${payload['mensaje']}');
      print(payload.containsKey('mensaje2')
          ? 'mensaje2 => ${payload['mensaje2']}'
          : 'no hay mensaje2');
    });
  }
}
