import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../engine/game_manager.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';
import '../utils/engine_helpers.dart'; // Needed for the dice roll & glitch
import '../widgets/event_modal.dart';
import '../widgets/item_grid_card.dart';
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
  // --- THE HALLUCINATION VARIABLES ---
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

    // THE RUSSIAN ROULETTE TRIGGER (5% Chance if Stressed & Cursed)
    if (scav.hiddenTrait != null && scav.stress > 50) {
      if (EngineHelpers.rollPercent(5)) {
        _isHallucinating = true;

        // Assign the nightmare color based on the hidden trait
        if (scav.hiddenTrait == 'ptsd') {
          _baseColor = AppTheme.alertRed;
          _terminalColor = AppTheme.alertRed;
        } else if (scav.hiddenTrait == 'paranoid') {
          _baseColor = Colors.purpleAccent;
          _terminalColor = Colors.purpleAccent;
        } else {
          // Psychosis
          _baseColor = AppTheme.warningYellow;
          _terminalColor = AppTheme.warningYellow;
        }
      }
    }
  }

  @override
  void dispose() {
    // THE GASLIGHT RESET: Destroy the evidence the second they leave the screen.
    if (widget.scavenger.stress > 0) {
      widget.scavenger.stress = 0;
    }
    super.dispose();
  }

  Color _getStateColor(ScavState state) {
    if (_isHallucinating) return _terminalColor; // Override colors if insane
    switch (state) {
      case ScavState.exploring:
        return AppTheme.terminalGreen;
      case ScavState.waitingForInput:
        return AppTheme.red;
      case ScavState.returning:
        return AppTheme.orangeAccent;
      case ScavState.dead:
        return AppTheme.red[900]!;
      case ScavState.idle:
        return AppTheme.green[300]!;
    }
  }

  Color _getItemColor(int tier) {
    switch (tier) {
      case 1:
        return AppTheme.grey;
      case 2:
        return AppTheme.blueAccent;
      case 3:
        return AppTheme.orangeAccent;
      default:
        return AppTheme.terminalGreen;
    }
  }

  IconData _getIconForType(String? type) {
    if (type == 'consumable' || type == 'food') return Icons.medical_services;
    if (type == 'armor') return Icons.security;
    if (type == 'scrap') return Icons.recycling;
    if (type == 'material') return Icons.science;
    return Icons.handyman;
  }

  // =========================================================================
  // THE TERMINAL PARSER
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final liveScavenger = context.watch<GameManager>().roster.firstWhere(
      (s) => s.id == widget.scavenger.id,
      orElse: () => widget.scavenger,
    );

    int scavHP = liveScavenger.hp.clamp(0, liveScavenger.maxHp);
    int capsFound = liveScavenger.backpack
        .where((item) => item.id == 'loot_caps')
        .fold(0, (sum, item) => sum + item.quantity);
    int trueWeight = liveScavenger.backpack
        .where((item) => item.id != 'loot_caps')
        .length;

    String displayName = _isHallucinating
        ? EngineHelpers.corruptText(liveScavenger.name.toUpperCase())
        : liveScavenger.name.toUpperCase();

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
            color: _baseColor, // Modded
          ),
        ),
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: _baseColor),
        // Modded
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: _baseColor.withValues(alpha: 0.5), // Modded
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
              TerminalContainer(
                height: 130,
                borderColor: _baseColor, // Modded
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: _baseColor, width: 2),
                        ), // Modded
                      ),
                      // TINT THE PORTRAIT IF HALLUCINATING
                      child: ColorFiltered(
                        colorFilter: _isHallucinating
                            ? ColorFilter.mode(_baseColor, BlendMode.modulate)
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              ),
                        child: Image.asset(
                          liveScavenger.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, color: _baseColor, size: 50),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayName,
                                  style: AppTheme.retroText(
                                    color: _terminalColor, // Modded
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  _isHallucinating
                                      ? "??"
                                      : '$scavHP / ${liveScavenger.maxHp}',
                                  style: AppTheme.retroText(
                                    color: _baseColor, // Modded
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(10, (index) {
                                double hpPercent = liveScavenger.maxHp > 0
                                    ? liveScavenger.hp / liveScavenger.maxHp
                                    : 0;
                                int filledBlocks = (hpPercent * 10).ceil();
                                bool isFilled = index < filledBlocks;

                                // JAGGED BLOCKS IF HALLUCINATING
                                double blockHeight = _isHallucinating
                                    ? EngineHelpers.rollStat(6, 16).toDouble()
                                    : 12.0;

                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: index < 9 ? 2.0 : 0,
                                    ),
                                    height: blockHeight,
                                    decoration: BoxDecoration(
                                      color: isFilled
                                          ? _terminalColor
                                          : _baseColor.withValues(alpha: 0.3),
                                      border: Border.all(
                                        color: isFilled
                                            ? _terminalColor
                                            : _baseColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Text(
                              "> ${liveScavenger.state.name.toUpperCase()} [${liveScavenger.state == ScavState.returning ? liveScavenger.formattedEta : liveScavenger.formattedDurationExplored}]",
                              style: AppTheme.retroText(
                                color: _getStateColor(liveScavenger.state),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "BACKPACK:",
                                  style: AppTheme.retroText(
                                    fontWeight: FontWeight.w900,
                                    color: _baseColor,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "$trueWeight/10",
                                  style: AppTheme.retroText(
                                    color: _baseColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "CAPS:",
                                  style: AppTheme.retroText(
                                    fontWeight: FontWeight.w900,
                                    color: _isHallucinating
                                        ? _baseColor
                                        : AppTheme.warningYellow,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "$capsFound",
                                  style: AppTheme.retroText(
                                    color: _isHallucinating
                                        ? _baseColor
                                        : AppTheme.warningYellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              if (liveScavenger.state == ScavState.waitingForInput)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bgBlack,
                      foregroundColor: _terminalColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: _terminalColor, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
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
              SizedBox(height: 8),
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

                      // THE FIX: Calling our beautifully isolated widget
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
              SizedBox(height: 16),

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
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDynamicActionButton(context, liveScavenger),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicActionButton(BuildContext context, Scavenger scav) {
    if (scav.state == ScavState.idle) {
      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[ DEPLOY ]')
            : '[ DEPLOY ]',
        borderColor: _baseColor,
        textColor: _terminalColor,
        onPressed: () {
          context.read<GameManager>().sendToWasteland(scav);
          Navigator.of(context).pop();
        },
      );
    } else if (scav.state == ScavState.exploring) {
      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[ RECALL SCAV ]')
            : '[ RECALL SCAV ]',
        onPressed: () => context.read<GameManager>().recallScavenger(scav),
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
      int scavCaps = 0;
      if (capIndex != -1) scavCaps = scav.backpack[capIndex].quantity;

      int calculatedFee = (scavCaps * 0.10).toInt();
      if (calculatedFee < 20) calculatedFee = 20;
      int reviveCost = scavCaps < calculatedFee ? scavCaps : calculatedFee;

      return TerminalButton(
        text: _isHallucinating
            ? EngineHelpers.corruptText('[REVIVE: $reviveCost CAPS]')
            : '[REVIVE: $reviveCost CAPS]',
        onPressed: () {
          context.read<GameManager>().reviveScavenger(scav);
        },
        borderColor: _isHallucinating ? _baseColor : AppTheme.red[900],
        textColor: _isHallucinating ? _terminalColor : AppTheme.red[900],
      );
    }
  }

  // =========================================================================
  // THE INVENTORY / MODALS (Remaining Unchanged for functional safety)
  // =========================================================================

  Widget _buildEquippedCard(
    BuildContext context,
    Scavenger liveScavenger,
    GameManager manager,
    String slotType,
    Item? item,
    StateSetter setModalState,
  ) {
    if (item == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppTheme.bgBlack,
          border: Border.all(
            color: AppTheme.green.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Text(
            "NO ${slotType.toUpperCase()}",
            style: AppTheme.retroText(
              color: AppTheme.green.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    String statText = item.type == 'weapon'
        ? "DMG: ${item.minStat}-${item.maxStat}"
        : "DR: ${item.minStat}";
    String imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    return InkWell(
      onTap: () {
        if (liveScavenger.state == ScavState.idle) {
          manager.unequipItem(liveScavenger, item.type);
          setModalState(() {});
        }
      },
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.bgBlack,
          border: Border.all(color: AppTheme.terminalGreen, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name.toUpperCase(),
              style: AppTheme.retroText(
                color: _getItemColor(item.tier),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _getIconForType(item.type),
                    color: _getItemColor(item.tier).withValues(alpha: 0.8),
                    size: 40,
                  ),
                ),
              ),
            ),
            Text(
              statText,
              style: AppTheme.retroText(
                color: AppTheme.terminalGreen,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (liveScavenger.state == ScavState.idle)
              Container(
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                color: AppTheme.orangeAccent.withValues(alpha: 0.2),
                child: Text(
                  "TAP TO UNEQUIP",
                  style: AppTheme.retroText(
                    color: AppTheme.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showInventoryModal(BuildContext context, Scavenger liveScavenger) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final manager = modalContext.watch<GameManager>();
            final stashGear = manager.globalStash
                .where(
                  (i) =>
                      i.type == 'weapon' ||
                      i.type == 'armor' ||
                      i.type == 'consumable' ||
                      i.type == 'food' ||
                      i.type == 'material',
                )
                .toList();
            final displayBackpackItems = liveScavenger.backpack
                .where((i) => i.id != 'loot_caps')
                .toList();
            int trueWeight = displayBackpackItems.length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: BoxDecoration(
                color: AppTheme.bgDark,
                border: Border(
                  top: BorderSide(color: AppTheme.green, width: 2),
                  left: BorderSide(color: AppTheme.green, width: 2),
                  right: BorderSide(color: AppTheme.green, width: 2),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "EQUIPMENT & STASH",
                      style: AppTheme.retroText(
                        color: AppTheme.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Divider(color: AppTheme.green, height: 1, thickness: 2),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: AppTheme.panelDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "[ EQUIPPED ]",
                                  style: AppTheme.retroText(
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildEquippedCard(
                                        context,
                                        liveScavenger,
                                        manager,
                                        "weapon",
                                        liveScavenger.equippedWeapon,
                                        setModalState,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: _buildEquippedCard(
                                        context,
                                        liveScavenger,
                                        manager,
                                        "armor",
                                        liveScavenger.equippedArmor,
                                        setModalState,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: AppTheme.green,
                            height: 1,
                            thickness: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "[ BACKPACK ]",
                                  style: AppTheme.retroText(
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "$trueWeight / 10",
                                  style: AppTheme.retroText(
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          displayBackpackItems.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    "NO LOOT ACQUIRED YET.",
                                    style: AppTheme.retroText(
                                      color: AppTheme.terminalGreen,
                                      fontSize: 16,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.85,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                  itemCount: displayBackpackItems.length,
                                  itemBuilder: (context, index) => ItemGridCard(
                                    item: displayBackpackItems[index],
                                    isEquipped:
                                        displayBackpackItems[index] ==
                                            liveScavenger.equippedWeapon ||
                                        displayBackpackItems[index] ==
                                            liveScavenger.equippedArmor,
                                    onTap: () => _showItemInspectionDialog(
                                      context,
                                      displayBackpackItems[index],
                                      false,
                                      liveScavenger,
                                      manager,
                                      setModalState,
                                    ),
                                  ),
                                ),
                          if (liveScavenger.state == ScavState.idle) ...[
                            SizedBox(height: 16),
                            const Divider(
                              color: AppTheme.green,
                              height: 1,
                              thickness: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "[ VAULT ARMORY ]",
                                    style: AppTheme.retroText(
                                      color: AppTheme.warningYellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${stashGear.length} ITEMS",
                                    style: AppTheme.retroText(
                                      color: AppTheme.warningYellow,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            stashGear.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      "NO GEAR IN STASH.",
                                      style: AppTheme.retroText(
                                        color: AppTheme.grey,
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.85,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                    itemCount: stashGear.length,
                                    itemBuilder: (context, index) =>
                                        ItemGridCard(
                                          item: stashGear[index],
                                          isEquipped:
                                              stashGear[index] ==
                                                  liveScavenger
                                                      .equippedWeapon ||
                                              stashGear[index] ==
                                                  liveScavenger.equippedArmor,
                                          onTap: () =>
                                              _showItemInspectionDialog(
                                                context,
                                                stashGear[index],
                                                true,
                                                liveScavenger,
                                                manager,
                                                setModalState,
                                              ),
                                        ),
                                  ),
                          ],
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showItemInspectionDialog(
    BuildContext context,
    Item item,
    bool isFromStash,
    Scavenger liveScavenger,
    GameManager manager,
    StateSetter parentSetState,
  ) {
    bool isInjecting = false;

    // --- THE LOCKDOWN CHECK ---
    bool isLockedDown =
        !isFromStash &&
        (liveScavenger.state == ScavState.returning ||
            liveScavenger.state == ScavState.dead);

    // --- THE FIX: Differentiate the error message ---
    String lockReason = liveScavenger.state == ScavState.dead
        ? "[ SUBJECT DECEASED ]"
        : "[ UNAVAILABLE EN ROUTE ]";

    String imagePath = item.imagePath ?? 'assets/images/items/${item.id}.png';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return Dialog(
              backgroundColor: AppTheme.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: TerminalContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _getItemColor(item.tier),
                              width: 1,
                            ),
                            color: AppTheme.bgBlack,
                          ),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getIconForType(item.type),
                              color: _getItemColor(item.tier),
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.toUpperCase(),
                                style: AppTheme.retroText(
                                  color: _getItemColor(item.tier),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "TIER ${item.tier} ${item.type.toUpperCase()}",
                                style: AppTheme.retroText(
                                  color: AppTheme.green.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      item.description ?? "No description available.",
                      style: AppTheme.retroText(
                        color: AppTheme.green.shade300,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (item.type == 'consumable' || item.type == 'food') ...[
                      Builder(
                        builder: (context) {
                          bool needsHealing =
                              liveScavenger.hp < liveScavenger.maxHp;
                          String btnLabel = item.type == 'food'
                              ? "[ CONSUME ]"
                              : "[ INJECT INSTANTLY ]";
                          String activeLabel = item.type == 'food'
                              ? "[ EATING... ]"
                              : "[ INJECTING... ]";
                          return ElevatedButton(
                            onPressed:
                                (needsHealing && !isInjecting && !isLockedDown)
                                ? () async {
                                    setLocalState(() => isInjecting = true);
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    manager.consumeItem(
                                      liveScavenger,
                                      item,
                                      isFromStash: isFromStash,
                                    );
                                    if (dialogContext.mounted) {
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.pop(dialogContext);
                                      }
                                    }
                                    parentSetState(() {});
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.bgBlack,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: (needsHealing && !isLockedDown)
                                    ? AppTheme.terminalGreen
                                    : AppTheme.grey,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: Text(
                              isLockedDown
                                  ? lockReason
                                  : isInjecting
                                  ? activeLabel
                                  : needsHealing
                                  ? btnLabel
                                  : "[ HP OPTIMAL ]", // <--- THE FIX
                              style: AppTheme.retroText(
                                color: (needsHealing && !isLockedDown)
                                    ? AppTheme.terminalGreen
                                    : AppTheme.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),
                      if (isFromStash && liveScavenger.state == ScavState.idle)
                        ElevatedButton(
                          onPressed: !isInjecting
                              ? () {
                                  if (manager.moveItemStashToBackpack(
                                    liveScavenger,
                                    item,
                                  )) {
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    parentSetState(() {});
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bgBlack,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: AppTheme.warningYellow,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            "[ MOVE 1 TO BACKPACK ]",
                            style: AppTheme.retroText(
                              color: AppTheme.warningYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (!isFromStash && liveScavenger.state == ScavState.idle)
                        ElevatedButton(
                          onPressed: !isInjecting
                              ? () {
                                  manager.moveItemBackpackToStash(
                                    liveScavenger,
                                    item,
                                  );
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  parentSetState(() {});
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bgBlack,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: AppTheme.orangeAccent,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            "[ RETURN 1 TO STASH ]",
                            style: AppTheme.retroText(
                              color: AppTheme.orangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: !isLockedDown
                            ? () {
                                manager.equipItem(
                                  liveScavenger,
                                  item,
                                  isFromStash: isFromStash,
                                );
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                                parentSetState(() {});
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.bgBlack,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: !isLockedDown
                                ? AppTheme.warningYellow
                                : AppTheme.grey,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          isLockedDown ? lockReason : "[ EQUIP ]",
                          style: AppTheme.retroText(
                            color: !isLockedDown
                                ? AppTheme.warningYellow
                                : AppTheme.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ), // <--- THE FIX
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
