import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../utils/app_theme.dart';
import '../widgets/scavenger_list_card.dart';
import '../widgets/terminal_button.dart';
import '../widgets/terminal_container.dart';
import 'facility_screen.dart';
import 'market_screen.dart';
import 'roster_screen.dart';
import 'stash_screen.dart';

class OverseerScreen extends StatelessWidget {
  const OverseerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameManager = context.watch<GameManager>();
    final allScavs = gameManager.roster;
    final globalStashCount = gameManager.globalStash.length;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          'COMMAND CENTER',
          style: AppTheme.retroText(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppTheme.green.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Status Bar
              TerminalContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        'assets/images/char/overseer.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, color: AppTheme.green, size: 50),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '[ ID: OVERSEER ]',
                            style: AppTheme.retroText(
                              color: AppTheme.terminalGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Divider(
                            color: AppTheme.green.withValues(alpha: 0.5),
                            height: 1,
                            thickness: 1,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'TREASURY : ${gameManager.caps} CAPS',
                            style: AppTheme.retroText(
                              color: AppTheme.warningYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'ARMORY   : $globalStashCount ITEMS',
                            style: AppTheme.retroText(
                              color: AppTheme.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'SYS_STAT : SECURE',
                            style: AppTheme.retroText(
                              color: AppTheme.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // 2. Terminal Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TerminalButton(
                      text: '[ROOMS]',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FacilityScreen(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TerminalButton(
                      text: '[ROSTER]',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RosterScreen(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TerminalButton(
                      text: '[STASH]',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StashScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              TerminalButton(
                text: "[ ACCESS MARKET ]",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MarketScreen()),
                ),
                padding: 16.0,
              ),
              SizedBox(height: 24),

              // 3. Personnel List Section
              Text(
                '--- PERSONNEL STATUS ---',
                style: AppTheme.retroText(
                  color: AppTheme.green,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              Expanded(
                child: allScavs.isEmpty
                    ? Center(
                        child: CustomPaint(
                          painter: DashedRectPainter(color: AppTheme.green),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                              horizontal: 24,
                            ),
                            color: AppTheme.bgBlack,
                            child: const BlinkingText(
                              '[ ROSTER EMPTY. NO PERSONNEL ASSIGNED. ]',
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allScavs.length,
                        itemBuilder: (context, index) => ScavengerListCard(
                          scavenger: allScavs[index],
                        ), // ONE LINE!
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              backgroundColor: AppTheme.bgDark,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppTheme.alertRed, width: 2),
                borderRadius: BorderRadius.zero,
              ),
              title: Text(
                'RESET SYSTEM?',
                style: AppTheme.retroText(
                  color: AppTheme.alertRed,
                  fontSize: 18,
                ),
              ),
              content: Text(
                'THIS WILL PERMANENTLY ERASE ALL SAVE PROFILES, DWELLERS, STASHED GEAR, AND TREASURY CAPS. ARE YOU ABSOLUTELY SURE?',
                style: AppTheme.retroText(color: AppTheme.green, fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(
                    '[ ABORT ]',
                    style: AppTheme.retroText(
                      color: AppTheme.green,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.read<GameManager>().hardResetGame();
                    Navigator.pop(dialogCtx);
                  },
                  child: Text(
                    '[ CONFIRM RESET ]',
                    style: AppTheme.retroText(
                      color: AppTheme.alertRed,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        backgroundColor: AppTheme.red[900],
        foregroundColor: AppTheme.white,
        tooltip: 'HIROSHIMA',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppTheme.alertRed, width: 2),
        ),
        child: const Icon(Icons.warning_amber_rounded),
      ),
    );
  }
}

// --- Custom painter for dashed border ---
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < size.width; i += gap * 2) {
      canvas.drawLine(
        Offset(i, 0),
        Offset((i + gap).clamp(0.0, size.width), 0),
        paint,
      );
    }
    for (double i = 0; i < size.width; i += gap * 2) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset((i + gap).clamp(0.0, size.width), size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += gap * 2) {
      canvas.drawLine(
        Offset(0, i),
        Offset(0, (i + gap).clamp(0.0, size.height)),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += gap * 2) {
      canvas.drawLine(
        Offset(size.width, i),
        Offset(size.width, (i + gap).clamp(0.0, size.height)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Blinking text widget ---
class BlinkingText extends StatefulWidget {
  final String text;

  const BlinkingText(this.text, {super.key});

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.text,
        style: AppTheme.retroText(
          color: AppTheme.green,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
