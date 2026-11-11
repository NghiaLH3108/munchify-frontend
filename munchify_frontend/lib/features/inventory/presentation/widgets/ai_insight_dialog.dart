import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/damaged_expired_record_entity.dart';
import '../../domain/usecases/analyze_damaged_expired_usecase.dart';

class AiInsightDialog extends StatefulWidget {
  final DamagedExpiredRecordEntity record;

  const AiInsightDialog({Key? key, required this.record}) : super(key: key);

  @override
  State<AiInsightDialog> createState() => _AiInsightDialogState();
}

class _AiInsightDialogState extends State<AiInsightDialog> {
  bool _isLoading = true;
  String? _errorMessage;
  late DamagedExpiredRecordEntity _record;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = sl<AnalyzeDamagedExpiredUseCase>();
    final result = await useCase.execute(_record.recordId);

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (updatedRecord) {
          setState(() {
            _record = updatedRecord;
            _isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String insight = 'Đang chờ phân tích từ AI hoặc không có dữ liệu.';
    String cause = 'Chưa xác định do thiếu dữ liệu AI.';
    String proposedAction = 'Vui lòng kiểm tra kết nối mạng hoặc API Key.';

    if (_record.aiAnalysis != null && _record.aiAnalysis!.isNotEmpty) {
      try {
        final Map<String, dynamic> aiData = jsonDecode(_record.aiAnalysis!);
        insight = aiData['insight'] ?? insight;
        cause = aiData['cause'] ?? cause;
        proposedAction = aiData['proposedAction'] ?? proposedAction;
      } catch (e) {
        insight = _record.aiAnalysis!; // fallback to raw string
      }
    }

    final batchDisplay = _record.batchCode ??
        (_record.importDetailId != null
            ? 'IMP-${_record.importDetailId}'
            : 'BATCH-${_record.createdAt.year}-P${_record.productId}');

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
              padding: const EdgeInsets.fromLTRB(28, 24, 20, 16),
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
                              child: const Text('DeepSeek AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF001B3F))),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: Color(0xFF5A4138)),
                            children: [
                              const TextSpan(text: 'Phân tích tự động tồn kho & đề xuất tối ưu cho lô '),
                              TextSpan(text: '#$batchDisplay', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', color: Color(0xFF1B1C1A))),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Re-analyze Button
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFA43700)),
                    tooltip: 'Phân tích lại AI',
                    onPressed: _isLoading ? null : _runAnalysis,
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
              child: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(80),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFA43700)),
                          SizedBox(height: 24),
                          Text('AI Copilot đang phân tích dữ liệu lô hàng trực tiếp...', style: TextStyle(color: Color(0xFF5A4138), fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ),
                  )
                : _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFBA1A1A), size: 48),
                            const SizedBox(height: 16),
                            Text(_errorMessage!, style: const TextStyle(color: Color(0xFFBA1A1A), fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _runAnalysis,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA43700), foregroundColor: Colors.white),
                            )
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
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
                              Text(_record.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B1C1A))),
                              const SizedBox(height: 4),
                              Text('SKU: P${_record.productId.toString().padLeft(3, '0')} • Tồn: ${_record.quantity} ${_record.unitName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA43700))),
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
                              const Text('• Phân tích từ DeepSeek AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFBA1A1A))),
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
                              const Text('• Khuyến nghị tối ưu hao hụt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005AB7))),
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
                  onPressed: _isLoading ? null : () => Navigator.pop(context, true),
                  icon: const Icon(Icons.delete_forever, color: Colors.white, size: 18),
                  label: const Text('Approve Write-off (Deduct Stock)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : const Color(0xFFBA1A1A),
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
