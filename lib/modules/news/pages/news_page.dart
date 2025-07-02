import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/data/models/news_model.dart';
import 'package:flutter_app_base/modules/custom_app_bar.dart';
import 'package:flutter_app_base/modules/news/providers/news_data_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NewsDataProvider(
      builder: (data) => _buildContent(context, data),
    );
  }

  Widget _buildContent(BuildContext context, NewsData data) {
    print('NewsPage: isInitialLoading = ${data.isInitialLoading}');

    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: CustomAppBar(title: 'Environmental News'),
      body: data.isInitialLoading
          ? _buildLoadingState()
          : data.news.isEmpty
              ? _buildEmptyState(context)
              : _buildNewsList(context, data.news),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: CustomTheme.primaryGreen),
          SizedBox(height: 24),
          Text(
            'Loading latest environmental news...',
            style: TextStyle(
              fontSize: 16,
              color: CustomTheme.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: CustomTheme.grey400,
            ),
            const SizedBox(height: 24),
            const Text(
              'No News Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CustomTheme.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We couldn\'t load any environmental news at the moment.',
              style: TextStyle(
                fontSize: 16,
                color: CustomTheme.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => newsService.refreshNews(context),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, List<NewsModel> newsList) {
    return RefreshIndicator(
      color: CustomTheme.primaryGreen,
      onRefresh: () => newsService.refreshNews(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: newsList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildNewsCard(newsList[index]),
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openNewsUrl(news.url),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (news.urlToImage.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  news.urlToImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    width: double.infinity,
                    color: CustomTheme.grey200,
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: CustomTheme.grey400,
                    ),
                  ),
                ),
              ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source and date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CustomTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          news.source,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: CustomTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatPublishedDate(news.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: CustomTheme.grey600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    news.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomTheme.grey600,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Author and read more
                  Row(
                    children: [
                      if (news.author.isNotEmpty && news.author != 'Unknown')
                        Expanded(
                          child: Text(
                            'By ${news.author}',
                            style: TextStyle(
                              fontSize: 12,
                              color: CustomTheme.grey600,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        'Read more →',
                        style: TextStyle(
                          fontSize: 12,
                          color: CustomTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPublishedDate(String publishedAt) {
    try {
      final date = DateTime.parse(publishedAt);

      // Format the date so it looks like "1 Jan 2023, 14:00"
      final month = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][date.month - 1];
      final day = date.day.toString().padLeft(2, '0');
      final year = date.year.toString();
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _openNewsUrl(String url) async {
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
