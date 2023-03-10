import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:voicerra/db/notes_database.dart';
import 'package:voicerra/model/note.dart';
import 'package:voicerra/Screens/edit_note_page.dart';
import 'package:voicerra/Screens/note_detail_page.dart';
import 'package:voicerra/widget/customappbar.dart';
import 'package:voicerra/widget/note_card_widget.dart';
import 'package:iconsax/iconsax.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  Widget buildNotes() => MasonryGridView.count(
    shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        itemCount: notes.length,
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));

              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );

  late List<Note> notes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  _add() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditNotePage()),
    );

    refreshNotes();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : notes.isEmpty
                        ? Container(
                            height:
                                MediaQuery.of(context).copyWith().size.height,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.note_1,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  size: 120,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'empty!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 22,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer),
                                ),
                              ],
                            ),
                          )
                        : SafeArea(
                            minimum: const EdgeInsets.only(top: 150),
                            child: Container(
                                height: MediaQuery.of(context)
                                    .copyWith()
                                    .size
                                    .height,
                                alignment: Alignment.topCenter,
                                child: buildNotes()),
                          ),
              ),
            ),
            SafeArea(
              child: MyAppBar(
                title: 'Notes',
                onIconTap: _add,
                iconName: Iconsax.add,
              ),
            ),
          ],
        ),
      );
}
