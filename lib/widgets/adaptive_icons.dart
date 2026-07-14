import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AdaptiveIcons {
  const AdaptiveIcons._();

  static final book = Platform.isIOS ? CupertinoIcons.book : Icons.menu_book_rounded;
  static final bookmark = Platform.isIOS ? CupertinoIcons.bookmark : Icons.bookmark_outline_rounded;
  static final bookmarkAdd = Platform.isIOS ? CupertinoIcons.bookmark : Icons.bookmark_add_outlined;
  static final bookmarkAdded = Platform.isIOS
      ? CupertinoIcons.bookmark_solid
      : Icons.bookmark_added_rounded;
  static final close = Platform.isIOS ? CupertinoIcons.xmark : Icons.close_rounded;
  static final search = Platform.isIOS ? CupertinoIcons.search : Icons.search_rounded;
  static final settings = Platform.isIOS ? CupertinoIcons.settings : Icons.settings_rounded;
  static final share = Platform.isIOS ? CupertinoIcons.share : Icons.share_rounded;
  static final sortBy = Platform.isIOS ? CupertinoIcons.sort_down : Icons.sort_rounded;
  static final trash = Platform.isIOS ? CupertinoIcons.trash : Icons.delete_outline_rounded;
  static final download = Platform.isIOS ? CupertinoIcons.cloud_download : Icons.download_outlined;
  static final downloadDone = Platform.isIOS
      ? CupertinoIcons.checkmark_circle
      : Icons.download_done_outlined;
  static final link = Platform.isIOS ? CupertinoIcons.link : Icons.link_outlined;
  static final email = Platform.isIOS ? CupertinoIcons.envelope : Icons.email_outlined;
}
