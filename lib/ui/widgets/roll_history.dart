import 'package:flutter/material.dart';
import '../../models/roll_result.dart';
import 'result_display_builder.dart';
import '../../presets/wilderness.dart';
import '../theme/juice_theme.dart';

/// Scrollable roll history widget with pagination for performance.
/// 
/// ## Performance Optimizations
/// 
/// This widget uses several techniques to minimize rebuilds and handle large lists:
/// - **Pagination**: Only loads [_pageSize] items at a time, loading more on scroll
/// - `cacheExtent`: Pre-renders items beyond the viewport for smoother scrolling
/// - `RepaintBoundary`: Isolates each card's repaint region (important for InkWell)
/// - Memoized `now`: DateTime.now() is computed once per list build, not per card
/// - See `_RollHistoryCard` for additional per-card optimizations
/// 
/// ## Pagination Strategy
/// 
/// - Initial load: First [_pageSize] items (50)
/// - On scroll near bottom: Load next page
/// - Maximum in view: Unlimited (loads progressively)
/// - New items added at top are always visible immediately
class RollHistory extends StatefulWidget {
  final List<RollResult> history;
  final void Function(int environmentRow, int typeRow)? onSetWildernessPosition;

  const RollHistory({
    super.key, 
    required this.history,
    this.onSetWildernessPosition,
  });

  @override
  State<RollHistory> createState() => _RollHistoryState();
}

class _RollHistoryState extends State<RollHistory> {
  /// Number of items to load per page
  static const int _pageSize = 50;
  
  /// Scroll threshold to trigger loading more (pixels from bottom)
  static const double _loadMoreThreshold = 200.0;
  
  final ScrollController _scrollController = ScrollController();
  
  /// Number of items currently loaded/visible
  int _loadedCount = _pageSize;
  
  /// Whether we're currently loading more items
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initialize loaded count based on history size
    _loadedCount = widget.history.length.clamp(0, _pageSize);
  }

  @override
  void didUpdateWidget(RollHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // When new items are added (history grows), keep them visible
    // New items are added at index 0, so we need to increase loaded count
    if (widget.history.length > oldWidget.history.length) {
      final newItemCount = widget.history.length - oldWidget.history.length;
      setState(() {
        _loadedCount = (_loadedCount + newItemCount).clamp(0, widget.history.length);
      });
    }
    // When history shrinks (cleared), reset pagination
    else if (widget.history.length < oldWidget.history.length) {
      setState(() {
        _loadedCount = widget.history.length.clamp(0, _pageSize);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (_loadedCount >= widget.history.length) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    // Load more when near the bottom
    if (maxScroll - currentScroll <= _loadMoreThreshold) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_loadedCount >= widget.history.length) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Use a microtask to allow the UI to show loading indicator
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _loadedCount = (_loadedCount + _pageSize).clamp(0, widget.history.length);
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute 'now' once for the entire list to avoid DateTime.now() per card
    final now = DateTime.now();
    final displayCount = _loadedCount.clamp(0, widget.history.length);
    final hasMore = displayCount < widget.history.length;
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      // Pre-render 500 logical pixels beyond viewport for smoother scrolling
      cacheExtent: 500,
      // +1 for loading indicator if there are more items
      itemCount: displayCount + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the bottom
        if (index >= displayCount) {
          return _buildLoadingIndicator();
        }
        
        final result = widget.history[index];
        // RepaintBoundary isolates each card's repaint region,
        // preventing InkWell ripples from triggering neighbor repaints
        return RepaintBoundary(
          child: _RollHistoryCard(
            key: ValueKey('${result.timestamp.millisecondsSinceEpoch}_$index'),
            result: result,
            index: index,
            now: now,
            onSetWildernessPosition: widget.onSetWildernessPosition,
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: JuiceTheme.parchmentDark50,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more... (${widget.history.length - _loadedCount} remaining)',
            style: TextStyle(
              fontSize: 12,
              color: JuiceTheme.parchmentDark50,
            ),
          ),
        ],
      ),
    );
  }
}

class _RollHistoryCard extends StatelessWidget {
  final RollResult result;
  final int index;
  final DateTime now;
  final void Function(int environmentRow, int typeRow)? onSetWildernessPosition;

  const _RollHistoryCard({
    super.key, 
    required this.result, 
    required this.index,
    required this.now,
    this.onSetWildernessPosition,
  });

  Color _getCategoryColor() {
    switch (result.type) {
      case RollType.fateCheck:
      case RollType.randomEvent:
      case RollType.discoverMeaning:
      case RollType.expectationCheck:
        return JuiceTheme.categoryOracle;
      case RollType.npcAction:
      case RollType.dialog:
      case RollType.nameGenerator:
        return JuiceTheme.categoryCharacter;
      case RollType.settlement:
      case RollType.location:
      case RollType.dungeon:
      case RollType.encounter:
      case RollType.weather:
        return JuiceTheme.categoryWorld;
      case RollType.challenge:
        return JuiceTheme.categoryCombat;
      case RollType.quest:
      case RollType.nextScene:
      case RollType.interruptPlotPoint:
        return JuiceTheme.categoryExplore;
      default:
        return JuiceTheme.sepia;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHED STATIC VALUES
  // These are computed once and reused across all card instances to avoid
  // creating new objects on every build.
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Cached shadow list - avoids recreating BoxShadow on every build
  static final _cardShadows = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Cached border radius - avoids recreating BorderRadius on every build
  static final _cardBorderRadius = BorderRadius.circular(8);
  
  /// Cached text styles - populated on first use from theme
  /// These avoid calling copyWith() on every build
  static TextStyle? _titleStyle;
  static TextStyle? _timestampStyle;
  
  TextStyle _getTitleStyle(ThemeData theme) {
    return _titleStyle ??= theme.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: JuiceTheme.parchment,
    );
  }
  
  TextStyle _getTimestampStyle(ThemeData theme) {
    return _timestampStyle ??= theme.textTheme.bodySmall!.copyWith(
      color: JuiceTheme.parchmentDark,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: JuiceTheme.inkDark60,
        borderRadius: _cardBorderRadius,
        border: Border(
          left: BorderSide(color: categoryColor, width: 4),
        ),
        boxShadow: _cardShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: _cardBorderRadius,
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.description,
                        style: _getTitleStyle(theme),
                      ),
                    ),
                    Text(
                      _formatTime(result.timestamp),
                      style: _getTimestampStyle(theme),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildResultDisplay(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (result.type) {
      case RollType.fateCheck:
        icon = Icons.help_outline;
        color = JuiceTheme.mystic;
        break;
      case RollType.nextScene:
        icon = Icons.theaters;
        color = JuiceTheme.info;
        break;
      case RollType.randomEvent:
        icon = Icons.flash_on;
        color = JuiceTheme.gold;
        break;
      case RollType.discoverMeaning:
        icon = Icons.lightbulb_outline;
        color = JuiceTheme.gold;
        break;
      case RollType.npcAction:
        icon = Icons.person;
        color = JuiceTheme.categoryCharacter;
        break;
      case RollType.payThePrice:
        icon = Icons.warning;
        color = JuiceTheme.danger;
        break;
      case RollType.quest:
        icon = Icons.map;
        color = JuiceTheme.rust;
        break;
      case RollType.interruptPlotPoint:
        icon = Icons.bolt;
        color = JuiceTheme.juiceOrange;
        break;
      case RollType.weather:
        icon = Icons.wb_sunny;
        color = JuiceTheme.info;
        break;
      case RollType.encounter:
        icon = Icons.explore;
        color = JuiceTheme.categoryExplore;
        break;
      case RollType.settlement:
        icon = Icons.location_city;
        color = JuiceTheme.categoryWorld;
        break;
      case RollType.objectTreasure:
        icon = Icons.diamond;
        color = JuiceTheme.gold;
        break;
      case RollType.challenge:
        icon = Icons.fitness_center;
        color = JuiceTheme.categoryCombat;
        break;
      case RollType.details:
        icon = Icons.palette;
        color = JuiceTheme.parchmentDark;
        break;
      case RollType.immersion:
        icon = Icons.visibility;
        color = JuiceTheme.juiceOrange;
        break;
      case RollType.location:
        icon = Icons.grid_on;
        color = JuiceTheme.rust;
        break;
      case RollType.abstractIcons:
        icon = Icons.image;
        color = JuiceTheme.success;
        break;
      case RollType.fate:
        icon = Icons.auto_awesome;
        color = JuiceTheme.mystic;
        break;
      case RollType.dialog:
        icon = Icons.chat;
        color = JuiceTheme.categoryCharacter;
        break;
      default:
        icon = Icons.casino;
        color = JuiceTheme.categoryUtility;
    }

    return Icon(icon, color: color, size: 20);
  }

  /// Builds the result display using the centralized ResultDisplayBuilder.
  Widget _buildResultDisplay(ThemeData theme) {
    return ResultDisplayBuilder(theme).buildDisplay(result);
  }

  /// Formats timestamp relative to [now] (passed from parent to avoid DateTime.now() per card)
  String _formatTime(DateTime time) {
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.description,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Dice: ${result.diceResults.join(', ')}'),
            Text('Total: ${result.total}'),
            if (result.interpretation != null)
              Text('Result: ${result.interpretation}'),
            const SizedBox(height: 16),
            Text(
              'Rolled at ${_formatFullTime(result.timestamp)}',
              style: const TextStyle(color: Colors.grey),
            ),
            // Show "Set as Current Position" for wilderness results
            if (result is WildernessAreaResult && onSetWildernessPosition != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final wilderness = result as WildernessAreaResult;
                    onSetWildernessPosition!(wilderness.envRoll, wilderness.typeRoll);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('📍 Set position: ${wilderness.interpretation}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Set as Current Position'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatFullTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
