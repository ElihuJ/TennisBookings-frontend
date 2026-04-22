import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../cloud_functions/dto/get_confirmed_players.dart';
import '../../../../../cloud_functions/dto/shared/basic_booking_payload.dart';
import '../../../../../cloud_functions/index.dart';
import '../../../../../global_helpers/index.dart';
import '../../../../../global_types/index.dart';
import '../../../../../global_widgets/index.dart';
import '../../../../../models/index.dart';
import '../../../../../screens/calendar/widgets/index.dart';
import '../../../../../state/index.dart';
import '../../../../../strings/index.dart';
import '../../../../../theme/index.dart';

class MyBookingsView extends StatefulHookConsumerWidget {
  const MyBookingsView({super.key});

  @override
  ConsumerState<MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends ConsumerState<MyBookingsView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);
    final now = DateTime.now().millisecondsSinceEpoch;

    final activeBookings = [...user.userBookings.where((b) => b.endTime >= now)]..sort((a, b) => a.startTime.compareTo(b.startTime));

    final pastBookings = [...user.userBookings.where((b) => b.endTime < now)]..sort((a, b) => b.startTime.compareTo(a.startTime));

    final displayedBookings = _selectedTab == 0 ? activeBookings : pastBookings;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          PrettyText(
            context.localeString(ProfileStrings.myBookings),
            fontSize: fontSize + 4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // ^ ====== Tab Bar ======
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabButton(
                  label: context.localeString(ProfileStrings.myBookingsUpcoming),
                  icon: Icons.upcoming_outlined,
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                _TabButton(
                  label: context.localeString(ProfileStrings.myBookingsPast),
                  icon: Icons.history_outlined,
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ^ ====== Tab Content ======
          if (displayedBookings.isEmpty)
            _EmptyState(
              title: _selectedTab == 0
                  ? context.localeString(ProfileStrings.myBookingsNoUpcoming)
                  : context.localeString(ProfileStrings.myBookingsNoPast),
              subtitle: _selectedTab == 0
                  ? context.localeString(ProfileStrings.myBookingsNoUpcomingSub)
                  : context.localeString(ProfileStrings.myBookingsNoPastSub),
              icon: _selectedTab == 0 ? Icons.event_available_outlined : Icons.history_edu_outlined,
            )
          else
            ...displayedBookings.map(
              (b) => _BookingCard(booking: b, isActive: _selectedTab == 0),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: AppColors.primaryGreen.withValues(alpha: 0.45)),
          const SizedBox(height: 16),
          PrettyText(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize + 4, color: AppColors.darkGreen, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          PrettyText(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends ConsumerStatefulWidget {
  const _BookingCard({required this.booking, required this.isActive});

  final Booking booking;
  final bool isActive;

  @override
  ConsumerState<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<_BookingCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Future<List<ConfirmedPlayerData>>? _playersFuture;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  Future<List<ConfirmedPlayerData>> _fetchPlayers() {
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);
    final payload = GetConfirmedPlayersDataPayload(
      payload: BasicBookingPayload(
        bookingId: widget.booking.id,
        clubId: widget.booking.clubId,
        courtId: widget.booking.courtId,
      ),
    );
    return cloudFunctions.getConfirmedPlayersData(payload).then((r) => r.data ?? []);
  }

  void _showPlayersOverlay(BuildContext context) {
    if (_overlayEntry != null) return;
    _playersFuture ??= _fetchPlayers();
    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 34),
          child: Align(
            alignment: Alignment.topLeft,
            child: _PlayersPopup(playersFuture: _playersFuture!),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePlayersOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onMoreTap(BuildContext context) {
    final user = ref.read(userProvider);
    final bookingAndUserContext = getBookingAndUserContext(
      booking: widget.booking,
      user: user,
      onlyMembers: false,
      isMemberOfClub: true,
    );
    final type = getBookingDetailsType(bookingAndUserContext);
    showBookingDetailsModal(context: context, booking: widget.booking, bookingDetailsType: type);
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppColors.primaryGreen;
      case BookingStatus.open:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.overridden:
        return Colors.orange;
      default:
        return AppColors.grey;
    }
  }

  String _capitalise(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);
    final statusColor = _statusColor(widget.booking.status);

    final confirmedCount = widget.booking.confirmedPlayerIds.length + 1;
    final maxPlayers = widget.booking.format == BookingFormat.singles ? 2 : 4;

    return Center(
      child: Container(
        width: 600,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          elevation: widget.isActive ? 4 : 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ^ ====== Header: title + status badge + delete ======
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PrettyText(
                        widget.booking.title,
                        style: TextStyle(fontSize: fontSize + 2, fontWeight: FontWeight.w700),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: widget.booking.status, color: statusColor),
                    if (widget.isActive) ...[
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onPressed: () => _onMoreTap(context),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // ^ ====== Date, time, location ======
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: prettyDateLocalFromEpoch(widget.booking.startTime),
                  fontSize: fontSize,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text: '${getLocalTimeFromEpoch(widget.booking.startTime)} – ${getLocalTimeFromEpoch(widget.booking.endTime)}',
                  fontSize: fontSize,
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: '${widget.booking.clubName} · ${widget.booking.courtName}',
                  fontSize: fontSize,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                // ^ ====== Chips: format, visibility, players ======
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(
                      icon: widget.booking.format == BookingFormat.singles ? Icons.person_outline : Icons.people_outline,
                      label: _capitalise(widget.booking.format.name),
                    ),
                    _InfoChip(
                      icon: widget.booking.private ? Icons.lock_outline : Icons.public_outlined,
                      label: widget.booking.private ? 'Private' : 'Public',
                    ),
                    CompositedTransformTarget(
                      link: _layerLink,
                      child: MouseRegion(
                        onEnter: (_) => _showPlayersOverlay(context),
                        onExit: (_) => _hidePlayersOverlay(),
                        child: _InfoChip(
                          icon: Icons.group_outlined,
                          label: '$confirmedCount / $maxPlayers',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayersPopup extends StatelessWidget {
  const _PlayersPopup({required this.playersFuture});

  final Future<List<ConfirmedPlayerData>> playersFuture;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
        ),
        child: FutureBuilder<List<ConfirmedPlayerData>>(
          future: playersFuture,
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            final players = snapshot.data ?? [];
            if (players.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: PrettyText(context.localeString(ProfileStrings.myBookingsNoPlayers)),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: players.map((p) => _PlayerRow(player: p)).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final ConfirmedPlayerData player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlayerIcon(player: player, size: 32),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                if (player.utrRating != null)
                  Text(
                    'UTR ${player.utrRating}',
                    style: TextStyle(fontSize: 11, color: AppColors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final BookingStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _capitalise(status.name),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    );
  }

  String _capitalise(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.fontSize});

  final IconData icon;
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: PrettyText(
            text,
            style: TextStyle(fontSize: fontSize - 1, color: AppColors.grey),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryGreen),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
