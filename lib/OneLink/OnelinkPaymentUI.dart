import 'dart:async';

import 'package:flutter/material.dart';

import '../DashBoard/AuthData.dart';
import '../DashBoard/dashBoard.dart';

import 'package:flutter/material.dart';

import 'OneLinkInquiryUI.dart';

class OneLinkPaymentUI extends StatefulWidget {
  final List<dynamic> oneLinkData;
  final List<String> inquiryStatuses;
  final List<String> paymentStatuses;
  const OneLinkPaymentUI({
    Key? key,
    required this.oneLinkData,
    required this.inquiryStatuses,
    required this.paymentStatuses,
  }) : super(key: key);


  @override
  State<OneLinkPaymentUI> createState() => _OneLinkUIState();
}

class _OneLinkUIState extends State<OneLinkPaymentUI> {
  final Set<int> _expandedIndexes = {};
  final List<String> timerOptions = ['15min', '1hour', '24hours', '48hours'];
  String selectedTimer = '15min';

  List<dynamic> _oneLinkData = [];
  List<dynamic> _filteredOneLinkData = [];
  bool isOneLinkLoading = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _statusRefreshTimer;
  @override
  void initState() {
    super.initState();
    _oneLinkData = widget.oneLinkData;
    _filteredOneLinkData = widget.oneLinkData;
    print(widget.inquiryStatuses);
    print(widget.paymentStatuses);
    _statusRefreshTimer = Timer.periodic(Duration(seconds: AuthData.timer), (timer) {
      _reloadOneLinkData();
    });
  }

  Future<void> _reloadOneLinkData() async {
    setState(() {
      _isLoading = true;
      _expandedIndexes.clear();
    });

    try {
      final data = await AuthData.fetchOneLinkPaymentHealth(
        AuthData.OnelinkPaymentAPiLink,
        selectedTimer,
      );

      setState(() {
        _oneLinkData = data;
        _filteredOneLinkData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load OneLink data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSearch(String query) {
    final q = query.toLowerCase();

    setState(() {
      _filteredOneLinkData = _oneLinkData.where((item) {
        final title =
        (item['companyTitle'] ?? '').toString().toLowerCase();
        final biller =
        (item['billerCode'] ?? '').toString().toLowerCase();
        return title.contains(q) || biller.contains(q);
      }).toList();
    });
  }
  Color getPaymentButtonColor() {
    final statuses =
    widget.inquiryStatuses.map((e) => e.toLowerCase()).toList();

    if (statuses.any((s) => s.contains('fail'))) {
      return Colors.red;
    }
    else if (statuses.any((s) => s.contains('warning'))) {
      return Colors.orange;
    }
    else if (statuses.any((s) => s.contains('success'))) {
      return Colors.green;
    }
    else {
      return Colors.grey;
    }
  }
  Widget _infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value?.toString() ?? '-',
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // This triggers when the user swipes back or presses back button
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
                (route) => false, // removes all previous routes
          );
          return false; // prevent default pop
        },
        child: Scaffold(
      body: Stack(
        children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001F3F),
              Color(0xFF002A5C),
              Color(0xFF003366),
              Color(0xFF004080),
              Color(0xFF3366CC),
              Color(0xFF6699FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ================= HEADER =================
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Back Button
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/dashboard',
                                  (route) => false,
                            );
                          },
                        ),

                        const SizedBox(width: 86),

                        // Logo
                        Image.asset(
                          'assets/images/1link-Payment.png',
                          height: 86,
                        ),

                        const SizedBox(width: 19),

                        // Text label
                      /*  const Text(
                          '1-link Payments',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),*/
                      ],
                    ),


                    const SizedBox(height: 8),

                    // Dropdown + Button (same row)
                    Row(
                      children: [
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedTimer,
                              items: timerOptions.map((option) {
                                return DropdownMenuItem(
                                  value: option,
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null &&
                                    val != selectedTimer) {
                                  setState(() {
                                    selectedTimer = val;
                                  });
                                  _reloadOneLinkData();
                                }
                              },
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                              dropdownColor:
                              const Color(0xFF004080),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              isOneLinkLoading = true; // show loader
                            });

                            try {
                              final data = await AuthData.fetchOneLinkInquiryHealth(AuthData.OnelinkInquiryAPiLink as String, selectedTimer);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OneLinkInquiryUI(oneLinkData: data, inquiryStatuses: widget.inquiryStatuses, paymentStatuses: widget.paymentStatuses ,),
                                ),
                              );
                            } catch (e) {
                              debugPrint('API call failed: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to load OneLink data')),
                              );
                            } finally {
                              setState(() {
                                isOneLinkLoading = false; // hide loader
                              });
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            side: BorderSide(color: getPaymentButtonColor()), // ✅ dynamic
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '1Link Inquiry',
                            style: TextStyle(
                              color: getPaymentButtonColor(), // ✅ dynamic text color
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Search
                    Container(
                      height: 42,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSearch,
                        style:
                        const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText:
                          'Search by company or biller code',
                          hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 13),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,
                              color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= LIST =================
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.orange),
                )
                    : _filteredOneLinkData.isEmpty
                    ? const Center(
                  child: Text('No data found',
                      style:
                      TextStyle(color: Colors.white)),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount:
                  _filteredOneLinkData.length,
                  itemBuilder: (context, index) {
                    final data =
                    _filteredOneLinkData[index];
                    final status = (data['serviceStatus'] ??
                        '')
                        .toString()
                        .toLowerCase();

                    Color cardColor;
                    if (status.contains('success')) {
                      cardColor = Colors.green
                          .withOpacity(0.55);
                    } else if (status
                        .contains('warning')) {
                      cardColor = Colors.orange
                          .withOpacity(0.55);
                    } else if (status.contains('fail')) {
                      cardColor =
                          Colors.red.withOpacity(0.55);
                    } else {
                      cardColor = Colors.white
                          .withOpacity(0.15);
                    }

                    final isExpanded =
                    _expandedIndexes.contains(index);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded
                              ? _expandedIndexes
                              .remove(index)
                              : _expandedIndexes
                              .add(index);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 250),
                        margin: const EdgeInsets.only(
                            bottom: 12),
                        padding:
                        const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        data['companyTitle'] ??
                                            '-',
                                        style:
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 4),
                                      Text(
                                        'Biller Code: ${data['billerCode'] ??
                                            '-'}',
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons
                                      .keyboard_arrow_up
                                      : Icons
                                      .keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              _infoRow('Failure Count',
                                  data['failureCount']),
                              _infoRow('Total Count',
                                  data['totalCount']),
                              _infoRow('Last Transaction',
                                  data['lastTransaction']),
                              _infoRow('Create Time',
                                  data['createTime']),
                              _infoRow('Failure Ratio',
                                  data['failureRatio']),
                              _infoRow('Status',
                                  data['serviceStatus']),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
          if (isOneLinkLoading)
      Container(
      color: Colors.black54, // semi-transparent overlay
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      ),
    ),
    ],
    ),
        ),
    );
  }
}


