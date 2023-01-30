
import 'dart:convert';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';




class MacosTerminal {

      
      late final terminal;
      late final terminalController;
      late final Pty pty;
      
      
      MacosTerminal(int maxLines) { 

        terminal = Terminal(
          maxLines: maxLines,
        );
        terminalController = TerminalController();
          
      } 




      void startPty() {
        pty = Pty.start(
          shell,
          columns: terminal.viewWidth,
          rows: terminal.viewHeight,
        );

        pty.output
            .cast<List<int>>()
            .transform(const Utf8Decoder())
            .listen(terminal.write);

        pty.exitCode.then((code) {
          terminal.write('the process exited with exit code $code');
        });

        terminal.onOutput = (data) {
          pty.write(const Utf8Encoder().convert(data));
        };

        terminal.onResize = (w, h, pw, ph) {
          pty.resize(h, w);
        };
      }   

      bool get isDesktop {
        if (kIsWeb) return false;
        return [
          TargetPlatform.windows,
          TargetPlatform.linux,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);
      }



      String get shell {
        if (Platform.isMacOS || Platform.isLinux) {
          return Platform.environment['SHELL'] ?? 'bash';
        }

        if (Platform.isWindows) {
          return 'wsl';
        }

        return 'sh';
      }

    
      
        
    

}