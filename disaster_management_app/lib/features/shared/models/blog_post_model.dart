import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String author;
  final String date;
  final DateTime createdAt;
  final String
      category; // 'disaster_preparedness', 'government_updates', 'alerts'
  final List<dynamic> tags;

  BlogPost({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.author,
    required this.date,
    required this.createdAt,
    required this.category,
    required this.tags,
  });

  factory BlogPost.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return BlogPost(
      id: doc.id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      author: data['author'] ?? 'Admin',
      date: data['date'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
      category: data['category'] ?? 'disaster_preparedness',
      tags: data['tags'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'author': author,
      'date': date,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'category': category,
      'tags': tags,
    };
  }
}
