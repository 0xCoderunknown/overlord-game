import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/engine_helpers.dart';
import '../widgets/dweller_inventory_sheet.dart';
import '../widgets/dweller_vitals_card.dart';
import '../widgets/event_modal.dart';
import '../widgets/terminal_button.dart';
import '../widgets/terminal_container.dart';
import '../widgets/terminal_log_line.dart';

class DwellerScreen extends StatefulWidget {
  final Scavenger scavenger;

  const DwellerScreen({super.key, required this.scavenger});

  @override
  State<DwellerScreen> createState() => _DwellerScreenState();
}

class _DwellerScreenState extends State<DwellerScreen> {
  bool _isHallucinating = false;
  Color _baseColor = AppTheme.green;
  Color _terminalColor = AppTheme.terminalGreen;

  @override
  void initState() {
    super.initState();
    _checkSanity();
  }

  void _checkSanity() {
    final scav = widget.scavenger;
    if (scav.hiddenTrait != null && scav.stress > 50) {
      if (EngineHelpers.rollPercent(5)) {
        _isHallucinating = true;
        if (scav.hiddenTrait == 'ptsd') {
          _baseColor = AppTheme.alertRed;
          _terminalColor = AppTheme.alertRed;
        } else if (scav.hiddenTrait == 'paranoid') {
          _baseColor = Colors.purpleAccent;
          _terminalColor = Colors.purpleAccent;
        } else {
          _baseColor = AppTheme.warningYellow;
          _terminalColor = AppTheme.warningYellow;
        }
      }
    }
  }

  @override
  void dispose() {
    if (widget.scavenger.stress > 0) {
      widget.scavenger.stress = 0;
    }
    super.dispose();
  }

  void _showInventoryModal(BuildContext context, Scavenger liveScavenger) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      isScrollControlled: true,
      builder: (_) => DwellerInventorySheet(scavenger: liveScavenger),
    );
  }

  Widget _buildDynamicActionButton(BuildContext context, Scavenger scav) {
    final manager = context.read<GameManager>();

    if (scav.state == ScavState.idle) {
      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[ DEPLOY ]')
            : '[ DEPLOY ]',
        borderColor: _baseColor,
        textColor: _terminalColor,
        onPressed: () {
          manager.sendToWasteland(scav);
          Navigator.of(context).pop();
        },
      );
    } else if (scav.state == ScavState.exploring) {
      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[ RECALL SCAV ]')
            : '[ RECALL SCAV ]',
        onPressed: () => manager.recallScavenger(scav),
        borderColor: _isHallucinating ? _baseColor : AppTheme.orangeAccent,
        textColor: _isHallucinating ? _terminalColor : AppTheme.orangeAccent,
      );
    } else if (scav.state == ScavState.returning) {
      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[ RETURNING ]')
            : '[ RETURNING ]',
        borderColor: _baseColor,
        textColor: _terminalColor,
        onPressed: () {},
      );
    } else if (scav.state == ScavState.waitingForInput) {
      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[ AWAITING ORDERS ]')
            : '[ AWAITING ORDERS ]',
        onPressed: () {},
        borderColor: _isHallucinating ? _baseColor : AppTheme.alertRed,
        textColor: _isHallucinating ? _terminalColor : AppTheme.alertRed,
      );
    } else {
      int capIndex = scav.backpack.indexWhere((item) => item.id == 'loot_caps');
      int scavCaps = capIndex != -1 ? scav.backpack[capIndex].quantity : 0;
      int calculatedFee = (scavCaps * 0.10).toInt();
      if (calculatedFee < 20) calculatedFee = 20;
      int reviveCost = scavCaps < calculatedFee ? scavCaps : calculatedFee;

      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[REVIVE: $reviveCost CAPS]')
            : '[REVIVE: $reviveCost CAPS]',
        onPressed: () => manager.reviveScavenger(scav),
        borderColor: _isHallucinating ? _baseColor : AppTheme.red900,
        textColor: _isHallucinating ? _terminalColor : AppTheme.red900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveScavenger = context.watch<GameManager>().roster.firstWhere(
      (s) => s.id == widget.scavenger.id,
      orElse: () => widget.scavenger,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          _isHallucinating
              ? EngineHelpers.corruptText('DWELLER DETAIL')
              : 'DWELLER DETAIL',
          style: AppTheme.retroText(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: _baseColor,
          ),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _baseColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: _baseColor.withValues(alpha: 0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DwellerVitalsCard(
                scavenger: liveScavenger,
                isHallucinating: _isHallucinating,
                baseColor: _baseColor,
                terminalColor: _terminalColor,
              ),
              const SizedBox(height: 16),
              if (liveScavenger.state == ScavState.waitingForInput)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bgBlack,
                      foregroundColor: _terminalColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _terminalColor, width: 2),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => EventModal(scavenger: liveScavenger),
                    ),
                    child: Text(
                      _isHallucinating
                          ? EngineHelpers.corruptText(
                              'ACTION REQUIRED: ENCOUNTER DETECTED',
                            )
                          : 'ACTION REQUIRED: ENCOUNTER DETECTED',
                      style: AppTheme.retroText(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              Text(
                _isHallucinating
                    ? EngineHelpers.corruptText('[ // LIVE ENCOUNTER FEED // ]')
                    : '[ // LIVE ENCOUNTER FEED // ]',
                style: AppTheme.retroText(
                  color: _baseColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TerminalContainer(
                  borderColor: _baseColor,
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12.0),
                    itemCount: liveScavenger.logs.length,
                    itemBuilder: (context, index) {
                      final log = liveScavenger
                          .logs[liveScavenger.logs.length - 1 - index];
                      return TerminalLogLine(
                        logText: log,
                        isHallucinating: _isHallucinating,
                        baseColor: _baseColor,
                        terminalColor: _terminalColor,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TerminalButton(
                      text: _isHallucinating
                          ? EngineHelpers.corruptText('[ INVENTORY ]')
                          : '[ INVENTORY ]',
                      borderColor: _baseColor,
                      textColor: _terminalColor,
                      onPressed: () =>
                          _showInventoryModal(context, liveScavenger),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDynamicActionButton(context, liveScavenger),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
