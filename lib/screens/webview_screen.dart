import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Channel {
  final String name;
  final String url;
  final IconData icon;

  const Channel({
    required this.name,
    required this.url,
    required this.icon,
  });
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _isLandscape = false;
  bool _keepScreenOn = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _currentTitle = 'Dooball Live TV';

  static const String _defaultUrl = 'https://www.dooball.co/tv/';

  final List<Channel> _presetChannels = const [
    Channel(
      name: 'Dooball TV (ดูบอลสด)',
      url: 'https://www.dooball.co/tv/',
      icon: Icons.live_tv_rounded,
    ),
    Channel(
      name: 'หน้าหลัก Dooball',
      url: 'https://www.dooball.co/',
      icon: Icons.sports_soccer_rounded,
    ),
    Channel(
      name: 'ตารางบอลวันนี้',
      url: 'https://www.dooball.co/program/',
      icon: Icons.calendar_month_rounded,
    ),
    Channel(
      name: 'ผลบอลสด LiveScore',
      url: 'https://www.dooball.co/livescore/',
      icon: Icons.scoreboard_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initWakelock();
    _initWebView();
  }

  Future<void> _initWakelock() async {
    try {
      if (_keepScreenOn) {
        await WakelockPlus.enable();
      }
    } catch (_) {}
  }

  void _initWebView() {
    final WebViewController controller = WebViewController();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B0E14))
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            final title = await controller.getTitle();
            if (title != null && title.isNotEmpty && mounted) {
              setState(() {
                _currentTitle = title;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == true) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_defaultUrl));

    _controller = controller;
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleWakeLock() async {
    final nextState = !_keepScreenOn;
    setState(() {
      _keepScreenOn = nextState;
    });
    try {
      if (nextState) {
        await WakelockPlus.enable();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เปิดโหมดค้างหน้าจอ (หน้าจอจะไม่ดับ)'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await WakelockPlus.disable();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ปิดโหมดค้างหน้าจอ'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          if (context.mounted) {
            _showExitDialog(context);
          }
        }
      },
      child: Scaffold(
        appBar: _isLandscape
            ? null
            : AppBar(
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_soccer_rounded,
                        color: Color(0xFF00E676),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DOOBALL',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 16,
                              color: Color(0xFF00E676),
                            ),
                          ),
                          Text(
                            _currentTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'รีเฟรช',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () => _controller.reload(),
                  ),
                  IconButton(
                    tooltip: _keepScreenOn ? 'ป้องกันจอดับ: เปิด' : 'ป้องกันจอดับ: ปิด',
                    icon: Icon(
                      _keepScreenOn ? Icons.screen_lock_portrait_rounded : Icons.screen_rotation_rounded,
                      color: _keepScreenOn ? const Color(0xFF00E676) : Colors.white60,
                    ),
                    onPressed: _toggleWakeLock,
                  ),
                  IconButton(
                    tooltip: 'เต็มจอแนวนอน',
                    icon: const Icon(Icons.fullscreen_rounded, size: 28),
                    onPressed: _toggleOrientation,
                  ),
                ],
                bottom: _isLoading
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(3.0),
                        child: LinearProgressIndicator(
                          value: _loadingProgress > 0 ? _loadingProgress : null,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                        ),
                      )
                    : null,
              ),
        drawer: _isLandscape ? null : _buildDrawer(),
        floatingActionButton: _isLandscape
            ? FloatingActionButton.small(
                backgroundColor: Colors.black54,
                child: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                onPressed: _toggleOrientation,
              )
            : null,
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                color: const Color(0xFF00E676),
                backgroundColor: const Color(0xFF171D29),
                onRefresh: () async {
                  await _controller.reload();
                },
                child: WebViewWidget(controller: _controller),
              ),
              if (_hasError)
                Container(
                  color: const Color(0xFF0B0E14),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ไม่สามารถโหลดเนื้อหาได้',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage.isNotEmpty ? _errorMessage : 'โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณ',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.white60),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                            });
                            _controller.reload();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            'ลองใหม่อีกครั้ง',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF10141D),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00897B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'DOOBALL TV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const Text(
                  'ดูบอลสด ถ่ายทอดสดครบทุกคู่',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          ..._presetChannels.map((channel) {
            return ListTile(
              leading: Icon(channel.icon, color: const Color(0xFF00E676)),
              title: Text(
                channel.name,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () {
                Navigator.pop(context);
                _controller.loadRequest(Uri.parse(channel.url));
              },
            );
          }),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.edit_note_rounded, color: Colors.white60),
            title: const Text('ใส่ลิงก์เว็บเอง (Custom URL)', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _showCustomUrlDialog();
            },
          ),
          ListTile(
            leading: Icon(
              _keepScreenOn ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: const Color(0xFF00E676),
            ),
            title: const Text('เปิดหน้าจอตลอดขณะดูบอล', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _toggleWakeLock();
            },
          ),
        ],
      ),
    );
  }

  void _showCustomUrlDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF171D29),
        title: const Text('ใส่ลิงก์เว็บไซต์'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://...',
            prefixIcon: Icon(Icons.link_rounded),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
            ),
            child: const Text('ไปที่เว็บ'),
            onPressed: () {
              String input = textController.text.trim();
              if (input.isNotEmpty) {
                if (!input.startsWith('http://') && !input.startsWith('https://')) {
                  input = 'https://$input';
                }
                _controller.loadRequest(Uri.parse(input));
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF171D29),
        title: const Text('ออกจากแอพ'),
        content: const Text('คุณต้องการออกจากแอพดูบอลหรือไม่?'),
        actions: [
          TextButton(
            child: const Text('ยกเลิก'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('ออกจากแอพ'),
            onPressed: () {
              Navigator.pop(ctx);
              SystemNavigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
