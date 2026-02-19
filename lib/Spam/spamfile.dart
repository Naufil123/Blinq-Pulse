import 'package:flutter/material.dart';

class SpamFile extends StatelessWidget {
  const SpamFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Top Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text('NS', style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Good Morning ", style: TextStyle(
                                  color: Colors.white, fontSize: 16)),
                              Padding(
                                padding: EdgeInsets.only(left: 105.0),
                                child: const Icon(Icons.notifications_none,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.help, color: Colors.white),
                            ],
                          ),
                          Text("Assalam o Alaikum", style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Registered Mobile",
                                  style: TextStyle(color: Colors.white70)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Text("Name",
                                    style: TextStyle(color: Colors.white70)),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("03298223398",
                                  style: TextStyle(color: Colors.white)),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text("Naufil Siddiqui",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Summary Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _summaryCard("Total Unpaid", "03", "12,000"),
                  _summaryCard("Current Month Expire", "02", "Amount"),
                ],
              ),

              const SizedBox(height: 20),

              // Current Month Unpaid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Current Month Unpaid", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("see all", style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text("NS", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: Text("Naufil Siddiqui")),
                    Padding(
                      padding: const EdgeInsets.only(right: 68.0),
                      child: const Icon (
                        Icons.arrow_forward_outlined, color: Colors.red,),
                    ),
                    const Text("RS6000", style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text("NS", style: TextStyle(color: Colors
                            .white)),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: Text("Naufil Siddiqui")),
                      Padding(
                        padding: const EdgeInsets.only(right: 68.0),
                        child: const Icon (
                          Icons.arrow_forward_outlined, color: Colors.red,),
                      ),
                      const Text("RS6000", style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Features",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Features
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // Important to avoid expanding infinitely
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 150,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Center(child: Text("Card 1")),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 150,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Center(child: Text("Card 2")),
                        ),
                      ),
                    ), Flexible(
                      fit: FlexFit.loose,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 150,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: Center(child: Text("Card 3")),
                        ),
                      ),
                    ),
                    // Add more cards if needed...
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String count, String amount) {
    return Expanded(

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.orange),

            // Unpaid bill icon
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
            Text(amount, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }


  Widget _futurecard(String title, String amount) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tv, size: 28, color: Colors.orange),
            // Unpaid bill icon
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(amount, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
