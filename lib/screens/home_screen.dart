import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:questlyy/providers/auth_provider.dart';
import 'package:questlyy/providers/bucket_list_provider.dart';
import 'package:questlyy/screens/login_screen.dart';
import 'package:questlyy/widgets/add_bucket_item_sheet.dart';
import 'package:questlyy/widgets/bucket_list_item_widget.dart';
import 'package:questlyy/widgets/life_map_painter.dart';
import 'package:questlyy/widgets/impact_difficulty_matrix.dart';
import 'package:questlyy/widgets/ai_generator_dialog.dart';
import 'package:questlyy/widgets/analytics_widgets.dart';
import 'package:questlyy/models/bucket_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  bool _showCompletedItems = true;
  String _viewMode = 'list';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddBucketItemSheet(),
    );
  }

  void _showLifeMapDialog() {
    final bucketListProvider = Provider.of<BucketListProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              const Text(
                'Your Life Map',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: LifeMapPainter(
                        bucketListProvider.bucketListItems,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Handle recommendation tap
        },
      ),
    );
  }

  Widget _buildTrendingList() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTrendingItem(
            'Visit Japan during cherry blossom season',
            Icons.flight,
          ),
          _buildTrendingItem(
            'Learn to play a musical instrument',
            Icons.music_note,
          ),
          _buildTrendingItem('Complete a marathon', Icons.directions_run),
          _buildTrendingItem('Start a side business', Icons.business),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(String title, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Inside the build method, add a loading indicator
  @override
  Widget build(BuildContext context) {
    final bucketListProvider = Provider.of<BucketListProvider>(context);

    // Show loading indicator while data is being loaded
    if (bucketListProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('QuestLyy')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Filter items based on selected category and completion status
    final filteredItems = bucketListProvider.bucketListItems.where((item) {
      final categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final completionMatch = _showCompletedItems || !item.isCompleted;
      return categoryMatch && completionMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuestLyy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              //   await authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My List'),
            Tab(text: 'Explore'),
            Tab(text: 'Life Map'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My List Tab
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: bucketListProvider.categories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  bucketListProvider.categories[index],
                                ),
                                selected:
                                    _selectedCategory ==
                                    bucketListProvider.categories[index],
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory =
                                        bucketListProvider.categories[index];
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _viewMode == 'list' ? Icons.grid_view : Icons.list,
                      ),
                      onPressed: () {
                        setState(() {
                          _viewMode = _viewMode == 'list' ? 'grid' : 'list';
                        });
                      },
                      tooltip: 'Change view',
                    ),
                    Switch(
                      value: _showCompletedItems,
                      onChanged: (value) {
                        setState(() {
                          _showCompletedItems = value;
                        });
                      },
                    ),
                    const Text(
                      'Show\nCompleted',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No bucket list items yet.\nAdd your first item!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : _viewMode == 'list'
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return BucketListItemWidget(item: item);
                        },
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return BucketListItemWidget(
                            item: item,
                            isGridView: true,
                          );
                        },
                      ),
              ),
            ],
          ),

          // Explore Tab - Recommendations
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Bucket List Generator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Let our AI suggest personalized bucket list ideas based on your interests and goals.',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.psychology),
                        label: const Text('Generate Ideas'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AIGeneratorDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Recommended for You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildRecommendationCard(
                'Travel the World',
                'Explore these top 10 destinations based on your interests',
                Icons.flight,
                Colors.blue,
              ),
              _buildRecommendationCard(
                'Learn a New Skill',
                'Popular skills that match your profile',
                Icons.school,
                Colors.orange,
              ),
              _buildRecommendationCard(
                'Adventure Activities',
                'Exciting adventures to add to your bucket list',
                Icons.landscape,
                Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Trending Now',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTrendingList(),
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Community Challenges',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.eco, color: Colors.white),
                        ),
                        title: const Text('30-Day Sustainability Challenge'),
                        subtitle: const Text(
                          'Join 2,458 others in making eco-friendly choices',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Join'),
                        ),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                          ),
                        ),
                        title: const Text('Fitness Bucket List'),
                        subtitle: const Text(
                          'Complete 10 fitness milestones in 60 days',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Join'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Life Map Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Life Map',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Visualize your bucket list items across different life categories',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: LifeMapPainter(
                                bucketListProvider.bucketListItems,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.fullscreen),
                            label: const Text('View Full Screen'),
                            onPressed: _showLifeMapDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Impact-Difficulty Matrix',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Prioritize your bucket list items based on impact and difficulty',
                        ),
                        const SizedBox(height: 16),
                        ImpactDifficultyMatrix(
                          items: bucketListProvider.bucketListItems,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Insights Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompletionStatsWidget(
                  items: bucketListProvider.bucketListItems,
                ),
                const SizedBox(height: 24),
                CategoryDistributionChart(
                  items: bucketListProvider.bucketListItems,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personalized Insights',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                          ),
                          title: const Text('Balance Your Goals'),
                          subtitle: const Text(
                            'Your bucket list is heavily focused on Travel. Consider adding items from other categories.',
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.trending_up,
                            color: Colors.green,
                          ),
                          title: const Text('Making Progress'),
                          subtitle: const Text(
                            'You\'ve completed 2 milestones this month. Keep up the good work!',
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                          ),
                          title: const Text('Plan Ahead'),
                          subtitle: const Text(
                            'You have 3 bucket list items due in the next 30 days.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
