import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/comment_model.dart';
import '../../data/comments_repository.dart';

class CommentsController extends AsyncNotifier<List<CommentModel>> {
  final String videoId;

  CommentsController(this.videoId);

  @override
  Future<List<CommentModel>> build() async {
    final repo = ref.watch(commentsRepositoryProvider);
    return repo.getComments(videoId);
  }

  Future<void> addComment(String content) async {
    final repo = ref.read(commentsRepositoryProvider);

    // Optimistic update could be complex with Auth, so let's just await for now
    // Or we can add a temp item.

    final newComment = await repo.addComment(
      videoId: videoId,
      content: content,
    );

    if (newComment != null) {
      final previousState = state.value ?? [];
      state = AsyncData([newComment, ...previousState]);
    }
  }
}

final commentsProvider =
    AsyncNotifierProvider.family<
      CommentsController,
      List<CommentModel>,
      String
    >(CommentsController.new);
