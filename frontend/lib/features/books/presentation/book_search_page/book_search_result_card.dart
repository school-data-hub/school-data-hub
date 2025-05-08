import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:schuldaten_hub/common/domain/env_manager.dart';
import 'package:schuldaten_hub/common/domain/session_manager.dart';
import 'package:schuldaten_hub/common/services/locator.dart';
import 'package:schuldaten_hub/common/theme/app_colors.dart';
import 'package:schuldaten_hub/common/theme/styles.dart';
import 'package:schuldaten_hub/common/utils/extensions.dart';
import 'package:schuldaten_hub/common/widgets/custom_expansion_tile/custom_expansion_tile.dart';
import 'package:schuldaten_hub/common/widgets/dialogs/long_textfield_dialog.dart';
import 'package:schuldaten_hub/common/widgets/document_image.dart';
import 'package:schuldaten_hub/common/widgets/unencrypted_image_in_card.dart';
import 'package:schuldaten_hub/common/widgets/upload_image.dart';
import 'package:schuldaten_hub/features/books/data/book_api_service.dart';
import 'package:schuldaten_hub/features/books/domain/book_helper.dart';
import 'package:schuldaten_hub/features/books/domain/book_manager.dart';
import 'package:schuldaten_hub/features/books/domain/models/book.dart';
import 'package:schuldaten_hub/features/books/domain/models/pupil_book.dart';
import 'package:schuldaten_hub/features/books/presentation/book_list_page/widgets/library_book_card.dart';
import 'package:watch_it/watch_it.dart';

class SearchResultBookCard extends WatchingWidget {
  final List<BookProxy> group;

  const SearchResultBookCard({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (group.isEmpty) return const SizedBox.shrink();

    final List<BookProxy> books = group;
    final BookProxy book = books.first;
    final descriptionTileController = createOnce<ExpansionTileController>(
          () => ExpansionTileController(),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: InkWell(
          onLongPress: () async {
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        book.author,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const Gap(5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final File? file = await uploadImageFile(context);
                            if (file == null) return;
                            await locator<BookManager>()
                                .patchBookImage(file, book.isbn);
                          },
                          child: UnencryptedImageInCard(
                            documentImageData: DocumentImageData(
                              documentTag: book.imageId,
                              documentUrl:
                              '${locator<EnvManager>().env!.serverUrl}${BookApiService.getBookImageUrl(book.isbn)}',
                              size: 140,
                            ),
                          ),
                        ),
                        const Gap(10),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                        const EdgeInsets.only(left: 15, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('ISBN:'),
                                const Gap(10),
                                Text(
                                  book.isbn.displayAsIsbn(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('LeseStufe:'),
                                const Gap(10),
                                Text(
                                  book.readingLevel,
                                  overflow: TextOverflow.fade,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 2,
                              children: [
                                const Text('Tags: '),
                                for (final tag in book.bookTags) ...[
                                  const Gap(5),
                                  Chip(
                                    padding: const EdgeInsets.all(2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    labelStyle: AppStyles.filterItemsTextStyle,
                                    label: Text(tag.name),
                                    backgroundColor: AppColors.backgroundColor,
                                  ),
                                ],
                              ],
                            ),
                            const Gap(10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  tilePadding: const EdgeInsets.all(0),
                  controller: descriptionTileController,
                  title: const Text(
                    'Beschreibung:',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  children: [
                    InkWell(
                      onTap: () async {
                        final String? description = await longTextFieldDialog(
                            title: 'Beschreibung',
                            labelText: 'Beschreibung',
                            textinField: book.description,
                            parentContext: context);
                        locator<BookManager>().updateBookProperty(
                          isbn: book.isbn,
                          description: description,
                        );
                      },
                      child: Text(
                        book.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.interactiveColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: books.map((book) {
                    return LibraryBookCard(book: book);
                  }).toList(),
                ),
                const Gap(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}