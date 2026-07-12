import 'package:equatable/equatable.dart';

class DownloadProgress extends Equatable {
  final int done;
  final int total;

  double get fraction => total == 0 ? 0 : done / total;

  const DownloadProgress({required this.done, required this.total});

  @override
  List<Object?> get props => [done, total];
}
