import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../domain/entities/damaged_expired_record_entity.dart';

class AiInsightDialog extends StatelessWidget {
  final DamagedExpiredRecordEntity record;

  const AiInsightDialog({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String insight = 'Financial loss detected. AI recommends write-off and reducing future import quantities to prevent further losses.';
    String cause = 'Nhập dư so với tốc độ bán thực tế.';
    String proposedAction = 'Giảm hạn mức đặt hàng tuần sau.';

    if (record.aiAnalysis != null && record.aiAnalysis!.isNotEmpty) {
      try {
        final Map<String, dynamic> aiData = jsonDecode(record.aiAnalysis!);
        insight = aiData['insight'] ?? insight;
        cause = aiData['cause'] ?? cause;
        proposedAction = aiData['proposedAction'] ?? proposedAction;
      } catch (e) {
        insight = record.aiAnalysis!; // fallback to raw string
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 680,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 24)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(28, 28, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EF).withOpacity(0.5),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFA43700), Color(0xFFFEB300)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('AI Inventory Strategy Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B1C1A))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFD7E2FF), borderRadius: BorderRadius.circular(12)),
                              child: const Text('Model v4.2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF001B3F))),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Color(0xFF5A4138)),
                            children: [
                              const TextSpan(text: 'Phân tích tự động tồn kho & đề xuất giảm thiểu hao hụt cho lô '),
                              TextSpan(text: '#BATCH-2026-P${record.productId}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Color(0xFF1B1C1A))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF5A4138)),
                    onPressed: () => Navigator.pop(context, false),
                  )
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                  // Insight Highlight
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF5F3EF), Colors.white, Color(0xFFFFF8E1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology, color: Color(0xFFA43700), size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ĐÁNH GIÁ THIỆT HẠI & ĐỀ XUẤT TỐI ƯU HÓA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFA43700), letterSpacing: 0.5)),
                              const SizedBox(height: 8),
                              Text(insight, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B1C1A), height: 1.5)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Structured Metrics
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFF5F3EF), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MẶT HÀNG & QUY CÁCH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5A4138))),
                              const SizedBox(height: 4),
                              Text(record.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B1C1A))),
                              const SizedBox(height: 4),
                              Text('SKU: P${record.productId.toString().padLeft(3, '0')} • Tồn: ${record.quantity} ${record.unitName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA43700))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFFFDAD6).withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NGUYÊN NHÂN AI XÁC ĐỊNH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
                              const SizedBox(height: 4),
                              Text(cause, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1B1C1A))),
                              const SizedBox(height: 4),
                              const Text('• Dữ liệu hệ thống ghi nhận', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFD7E2FF).withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('HÀNH ĐỘNG ĐỀ XUẤT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005AB7))),
                              const SizedBox(height: 4),
                              Text(proposedAction, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1B1C1A))),
                              const SizedBox(height: 4),
                              const Text('• Khuyến nghị từ Copilot', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005AB7))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Footer Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EF).withOpacity(0.6),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.undo, color: Color(0xFF5A4138), size: 18),
                    label: const Text('Keep & Cancel (Hủy & Giữ lại)', style: TextStyle(color: Color(0xFF1B1C1A), fontSize: 14)),
                    style: TextButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                    label: const Text('Approve Write-off (Deduct Stock)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBA1A1A),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
