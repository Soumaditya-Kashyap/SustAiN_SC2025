import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';

class AdminBlogScreen extends StatefulWidget {
  const AdminBlogScreen({Key? key}) : super(key: key);

  @override
  State<AdminBlogScreen> createState() => _AdminBlogScreenState();
}

class _AdminBlogScreenState extends State<AdminBlogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _blogPosts = [];
  String _selectedCategory = 'disaster_preparedness';
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _summaryController = TextEditingController();
  final _tagsController = TextEditingController();
  List<String> _tags = [];

  final Map<String, String> _categoryNames = {
    'disaster_preparedness': 'Safety Tips',
    'government_updates': 'Govt Updates',
    'alerts': 'Alert',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBlogPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _summaryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadBlogPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch blog posts from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection(AppConstants.blogCollection)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _blogPosts = querySnapshot.docs.map((doc) {
          final data = doc.data();
          // Ensure we have the document ID as the post ID
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading blog posts: $e');
      setState(() {
        // Fallback to mock data if there's an error
        _blogPosts = [
          ..._getPreparednessPostsData(),
          ..._getGovernmentUpdatesData(),
          ..._getAlertsData(),
        ];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getPreparednessPostsData() {
    return [
      {
        'id': '1',
        'title': 'How to Prepare for an Earthquake',
        'date': '12 March 2023',
        'author': 'Admin',
        'category': 'disaster_preparedness',
        'summary':
            'Essential steps to take before, during, and after an earthquake to stay safe.',
        'tags': ['Earthquake', 'Safety', 'Preparedness'],
        'content':
            '## Before an Earthquake\n1. **Secure heavy furniture** to walls...',
      },
      {
        'id': '2',
        'title': 'Flood Safety Precautions',
        'date': '5 April 2023',
        'author': 'Admin',
        'category': 'disaster_preparedness',
        'summary':
            'Critical flood safety measures everyone should know to protect their family and property.',
        'tags': ['Flood', 'Safety', 'Monsoon'],
        'content':
            '## Before a Flood\n1. **Understand your risk** - Know if your area is prone to flooding...',
      },
    ];
  }

  List<Map<String, dynamic>> _getGovernmentUpdatesData() {
    return [
      {
        'id': '3',
        'title': 'Government Launches New Disaster Alert System',
        'date': '3 June 2023',
        'author': 'Admin',
        'category': 'government_updates',
        'summary':
            'A nationwide alert system to provide instant disaster warnings through mobile phones.',
        'tags': ['Government', 'Alert System', 'Technology'],
        'content':
            'The Ministry of Disaster Management today launched a new nationwide alert system...',
      },
    ];
  }

  List<Map<String, dynamic>> _getAlertsData() {
    return [
      {
        'id': '4',
        'title': 'Heavy Rainfall Expected in Western Regions',
        'date': '10 September 2023',
        'author': 'Admin',
        'category': 'alerts',
        'summary':
            'Weather alert: Heavy rainfall predicted for the next 72 hours. Residents advised to take precautions.',
        'tags': ['Weather', 'Rainfall', 'Alert'],
        'content':
            '## URGENT WEATHER ALERT\n\nThe Meteorological Department has issued a heavy rainfall warning...',
      },
    ];
  }

  Future<void> _saveBlogPost() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _summaryController.text.isEmpty ||
        _tags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields and add at least one tag'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('d MMMM yyyy').format(now);

      // Convert tags to List<dynamic> to avoid any potential type issues
      final List<dynamic> tagsDynamic = _tags.map((tag) => tag).toList();

      final newPost = {
        'title': _titleController.text,
        'date': formattedDate,
        'author': 'Admin',
        'category': _selectedCategory,
        'summary': _summaryController.text,
        'tags': tagsDynamic,
        'content': _contentController.text,
        'createdAt': now.millisecondsSinceEpoch,
      };

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection(AppConstants.blogCollection)
          .add(newPost);

      // Add the post to the local list with the new ID
      final newPostWithId = Map<String, dynamic>.from(newPost);
      newPostWithId['id'] = docRef.id;

      setState(() {
        _blogPosts.insert(0, newPostWithId);
      });

      // Clear form fields
      _titleController.clear();
      _contentController.clear();
      _summaryController.clear();
      _tagsController.clear();
      setState(() {
        _tags = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blog post saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Switch to posts list tab
      _tabController.animateTo(0);
    } catch (e) {
      print('Error saving blog post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving blog post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _deleteBlogPost(String id) async {
    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection(AppConstants.blogCollection)
          .doc(id)
          .delete();

      // Remove from local list
      setState(() {
        _blogPosts.removeWhere((post) => post['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Blog post deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting blog post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting blog post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Blog Posts'),
                Tab(text: 'Create New'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Blog posts list tab
                _buildPostsListTab(),

                // Create new post tab
                _buildCreatePostTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsListTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_blogPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No blog posts yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(1);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Post'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlogPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _blogPosts.length,
        itemBuilder: (context, index) {
          final post = _blogPosts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final category = post['category'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categoryNames[category] ?? 'Other',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post['date'] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    _showDeleteConfirmationDialog(post['id'] as String);
                  },
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['summary'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (post['tags'] as List<dynamic>).map((tag) {
                    return Chip(
                      label: Text(tag as String),
                      backgroundColor:
                          _getCategoryColor(category).withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: _getCategoryColor(category),
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement edit functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit functionality coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String id) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Blog Post'),
        content: const Text(
          'Are you sure you want to delete this blog post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBlogPost(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post type selection
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Post Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildCategorySelector(
                        'disaster_preparedness',
                        'Safety Tips',
                        Icons.shield,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildCategorySelector(
                        'government_updates',
                        'Govt Updates',
                        Icons.public,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildCategorySelector(
                        'alerts',
                        'Alert',
                        Icons.warning,
                        Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Post Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 1,
          ),

          const SizedBox(height: 16),

          // Summary
          TextField(
            controller: _summaryController,
            decoration: InputDecoration(
              labelText: 'Summary',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              helperText:
                  'Brief description of the post (appears in blog list)',
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // Tags
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    helperText: 'Add keywords to categorize your post',
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addTag,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),

          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor:
                        _getCategoryColor(_selectedCategory).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: _getCategoryColor(_selectedCategory),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Content
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'Content',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              helperText: 'Supports markdown formatting',
            ),
            maxLines: 10,
          ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveBlogPost,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('PUBLISH POST'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(
    String category,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCategory == category;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'disaster_preparedness':
        return Icons.shield;
      case 'government_updates':
        return Icons.public;
      case 'alerts':
        return Icons.warning;
      default:
        return Icons.article;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'disaster_preparedness':
        return Colors.blue;
      case 'government_updates':
        return Colors.green;
      case 'alerts':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
