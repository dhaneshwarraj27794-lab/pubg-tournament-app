import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TournamentList(),
    );
  }
}

class TournamentList extends StatelessWidget {
  const TournamentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BGMI Tournaments")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tournaments')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No tournaments found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                          "Entry ₹${data['entry_fee']} | Prize ₹${data['prize']}"),
                      Text(
                          "Joined: ${data['joined']} / ${data['max_players']}"),

                      if (data['status'] == 'live') ...[
                        const SizedBox(height: 6),
                        Text("Room ID: ${data['room_id']}"),
                        Text("Password: ${data['room_password']}"),
                      ],

                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: data['joined'] >= data['max_players']
                            ? null
                            : () {
                                FirebaseFirestore.instance
                                    .collection('tournaments')
                                    .doc(data.id)
                                    .update({
                                  'joined': FieldValue.increment(1),
                                });
                              },
                        child: Text(
                          data['joined'] >= data['max_players']
                              ? "Full"
                              : "Join",
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
