import 'dart:convert';
import 'dart:io';
import 'dart:ffi' show Uint16, Uint32, Uint32Pointer, sizeOf;



import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:win32/win32.dart' hide MoveWindow;




// This is the max win32 username length. It is missing from the win32 package,
// so we'll just create our own constant.
const unLen = 256;

String getUsername() {
  return using<String>((arena) {
    final buffer = arena.allocate<Utf16>(sizeOf<Uint16>() * (unLen + 1));
    final bufferSize = arena.allocate<Uint32>(sizeOf<Uint32>());
    bufferSize.value = unLen + 1;
    final result = GetUserName(buffer, bufferSize);
    if (result == 0) {
      GetLastError();
      throw Exception(
          'Failed to get win32 username: error 0x${result.toRadixString(16)}');
    }
    return buffer.toDartString();
  });
}



final macosterminal = Terminal( maxLines: 10000,);
final terminalController = TerminalController();
late final Pty pty;




final terminalwidth = macosterminal.viewWidth.toString();
final terminalheight = macosterminal.viewHeight.toString();


var brightness = SchedulerBinding.instance.window.platformBrightness;
bool isDark = brightness == Brightness.dark;  

const titlebarcolorlight = Color.fromARGB(255, 226, 226, 226);
const titlebarcolordark = Color.fromARGB(255, 71,73,73);
//Color.fromARGB(255, 240, 241, 240) light theme titlebar



const windowcolorlight = Color.fromARGB(255, 255, 255, 255);
const windowcolordark = Color.fromARGB(255, 30,30,30);

//Color.fromRGBO(0, 0, 0, 0.7) dark transparent


// colors to be placed in a different location
final closeButton = WindowButtonColors(
  iconNormal: Colors.transparent,
  mouseOver: Colors.transparent,
  mouseDown: Colors.transparent,
  iconMouseOver: Colors.transparent,
  iconMouseDown: Colors.transparent,
);

final minimizeButton = WindowButtonColors(
  iconNormal: Colors.transparent,
  mouseOver: Colors.transparent,
  mouseDown: Colors.transparent,
  iconMouseOver: Colors.transparent,
  iconMouseDown: Colors.transparent,
);

final maximizeButton = WindowButtonColors(
  iconNormal: Colors.transparent,
  mouseOver: Colors.transparent,
  mouseDown: Colors.transparent,
  iconMouseOver: Colors.transparent,
  iconMouseDown: Colors.transparent,
  
);


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();
  Window.initialize();

  Window.setEffect(effect: WindowEffect.transparent);
  
  doWhenWindowReady(() async {

    await windowManager.setAsFrameless();
    //await windowManager.setHasShadow(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    const initialSize = Size(600, 405);

    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    windowManager.show();


  });



  runApp(const MyApp());
  


  
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {


  


    return MaterialApp(
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [

              
              /// Fake window border
              Container(
                
                decoration: BoxDecoration(
                  color: isDark ? windowcolordark : windowcolorlight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Container(
                  margin: const EdgeInsets.all(0.1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: child!,
                  ),
                ),
              ),

              

              /// Resizable Border
              const DragToResizeArea(
                enableResizeEdges: [
                  ResizeEdge.topLeft,
                  ResizeEdge.top,
                  ResizeEdge.topRight,
                  ResizeEdge.left,
                  ResizeEdge.right,
                  ResizeEdge.bottomLeft,
                  ResizeEdge.bottomLeft,
                  ResizeEdge.bottomRight,
                ],
                child: SizedBox(),
              ),


              
             
             
              //TITLEBAR
              Container(
                height: 31,
                width: double.infinity,
                decoration:BoxDecoration(
                  color: isDark ? titlebarcolordark : titlebarcolorlight,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      offset: Offset(0, -2)
                    )
                  ]
                ),
                child: MoveWindow(
                  child: Center(
                    child: Material(
                      color: isDark ? titlebarcolordark : titlebarcolorlight,
                      child: Text(
                        "${getUsername()} - cmd -- ${terminalwidth}x$terminalheight",
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
              



             
              

              
              
              //BUTTONS
              Row(children: [

                const SizedBox(height: 10,width: 8.586),
              
                Container(
                  height: 12.7,
                  width: 12.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 255, 95, 87),
                    border: Border.all(width: 0.3, color: const Color(0xCCB4604F)),
                  ),
                  child: CloseWindowButton(colors: closeButton,),
                  
                  
                ),

                const SizedBox(height: 10,width: 8),
                
                Container(
                  height: 12.7,
                  width: 12.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(193, 255, 189, 46),
                    border: Border.all(width: 0.3, color: const Color(0xCCCBA049)),
                  ),
                  child: MinimizeWindowButton(colors: minimizeButton,),
                  
                  
                ),
                
                const SizedBox(height: 10,width: 8.2),

                Container(
                  height: 12.7,
                  width: 12.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(204, 38, 200, 65),
                    border: Border.all(width: 0.3, color: const Color(0xCC599548)),
                  ),
                  child: MaximizeWindowButton(colors: maximizeButton,),
                  
                ),

                
                const Padding(padding:EdgeInsets.only(bottom: 35)),

              ]),
              
            ],
          ),
        );
      },
      title: 'Flutter Demo',
      theme: ThemeData(
            primarySwatch: Colors.blue,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            scrollbarTheme: const ScrollbarThemeData().copyWith(
              thickness: MaterialStateProperty.all(6.15),
            )),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
  
  
}




class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

   void startPty() {
    pty = Pty.start(
      shell,
      columns: macosterminal.viewWidth,
      rows: macosterminal.viewHeight,
    );

    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(macosterminal.write);

    pty.exitCode.then((code) {
      macosterminal.write('the process exited with exit code $code');
    });

    macosterminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    macosterminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }   

  @override
  void initState() {
    super.initState();

    
    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) startPty();
      },
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:
        
          
      
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 240, 241, 240),
                width: 0.2,
                style: BorderStyle.solid,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 33 ,left: 8),
              child: SafeArea(
                child: TerminalView(
                  theme: TerminalTheme(cursor: Color(0XFFAEAFAD),
                    selection: Color(0XFFAEAFAD),
                    foreground: isDark ? Colors.white : Colors.black,
                    background: Color(0XFF000000),
                    black: Color(0XFF000000),
                    red: Color(0XFFCD3131),
                    green: Color(0XFF0DBC79),
                    yellow: Color(0XFFE5E510),
                    blue: Color(0XFF2472C8),
                    magenta: Color(0XFFBC3FBC),
                    cyan: Color(0XFF11A8CD),
                    white: Color(0XFFE5E5E5),
                    brightBlack: Color(0XFF666666),
                    brightRed: Color(0XFFF14C4C),
                    brightGreen: Color(0XFF23D18B),
                    brightYellow: Color(0XFFF5F543),
                    brightBlue: Color(0XFF3B8EEA),
                    brightMagenta: Color(0XFFD670D6),
                    brightCyan: Color(0XFF29B8DB),
                    brightWhite: Color(0XFFFFFFFF),
                    searchHitBackground: Color(0XFFFFFF2B),
                    searchHitBackgroundCurrent: Color(0XFF31FF26),
                    searchHitForeground: Color(0XFF000000),),
                  macosterminal,
                  controller: terminalController,
                  autofocus: true,
                  backgroundOpacity: 0,
                  onSecondaryTapDown: (details, offset) async {
                    final selection = terminalController.selection;
                    if (selection != null) {
                      final text = macosterminal.buffer.getText(selection);
                      terminalController.clearSelection();
                      await Clipboard.setData(ClipboardData(text: text));
                    } else {
                      final data = await Clipboard.getData('text/plain');
                      final text = data?.text;
                      if (text != null) {
                        macosterminal.paste(text);
                      }
                    }
                  },
                ),
              ),
            ),
          ),

          

      );
    
  }
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
          return 'cmd.exe';
        }

        return 'sh';
      }

















































 
  



 
 




           
                


                
                    
                                                            
                      
                   







