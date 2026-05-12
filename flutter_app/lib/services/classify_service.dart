import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';

class ClassifyService {
  /// HF Space URL for direct classification (bypasses Vercel timeout)
  static const String _hfSpaceUrl = 'https://omarh353111-khorda-yolo.hf.space';

  /// Category mapping matching backend ai/classifier.py
  static const Map<String, String> _categoryMap = {
    'bed': 'furniture', 'chair': 'furniture', 'cabinet': 'furniture',
    'cupboard': 'furniture', 'curtain': 'furniture', 'lamp': 'furniture',
    'mirror': 'furniture', 'sofa': 'furniture', 'table': 'furniture',
    'wardrobe': 'furniture', 'Wardrobe': 'furniture',
    'Dressing Table': 'furniture', 'food_trip': 'furniture',
    'Food trip': 'furniture', 'safe': 'furniture', 'office': 'furniture',
    'laptop': 'electronics', 'computer': 'electronics',
    'mobile_phone': 'electronics', 'phone': 'electronics',
    'tv': 'electronics', 'camera': 'electronics',
    'headphone': 'electronics', 'airpods': 'electronics',
    'speaker': 'electronics', 'receiver': 'electronics',
    'router': 'electronics', 'printer': 'electronics',
    'keyboard': 'electronics', 'watch': 'electronics',
    'controller': 'electronics', 'ps_console': 'electronics',
    'pc_case': 'electronics',
    'washing_machine': 'appliances', 'fridge': 'appliances',
    'refrigerator': 'appliances', 'cooker': 'appliances',
    'stove': 'appliances', 'microwave': 'appliances',
    'blender': 'appliances', 'ac_unit': 'appliances',
    'fan': 'appliances', 'heater': 'appliances',
    'water_heater': 'appliances', 'iron': 'appliances',
    'vacuum_cleaner': 'appliances', 'vacuum cleaner': 'appliances',
    'water_filter': 'appliances', 'gas_cylinder': 'appliances',
    'gas_bottle': 'appliances', 'freighter': 'appliances',
    'korda': 'scrap_metals', 'scrap_metal': 'scrap_metals',
    'copper_wire': 'scrap_metals', 'wire': 'scrap_metals',
    'aluminum': 'scrap_metals', 'equipment': 'scrap_metals',
    'mator': 'scrap_metals',
    'car': 'cars',
    'building': 'real_estate',
    'book': 'books',
  };

  /// Arabic labels for detected classes
  static const Map<String, String> _classLabelsAr = {
    'bed': 'سرير', 'chair': 'كرسي', 'cabinet': 'خزانة',
    'cupboard': 'دولاب', 'curtain': 'ستارة', 'lamp': 'لمبة / أباجورة',
    'mirror': 'مرآة', 'sofa': 'كنبة', 'table': 'طاولة / ترابيزة',
    'wardrobe': 'دولاب ملابس', 'Wardrobe': 'دولاب ملابس',
    'Dressing Table': 'تسريحة', 'food_trip': 'سفرة', 'Food trip': 'سفرة',
    'safe': 'خزنة', 'office': 'مكتب / أوفيس',
    'laptop': 'لابتوب', 'computer': 'كمبيوتر',
    'mobile_phone': 'موبايل', 'phone': 'موبايل',
    'tv': 'تلفزيون', 'camera': 'كاميرا',
    'headphone': 'سماعات', 'airpods': 'سماعات إيربودز',
    'speaker': 'سبيكر', 'receiver': 'رسيفر',
    'router': 'راوتر', 'printer': 'طابعة',
    'keyboard': 'كيبورد', 'watch': 'ساعة',
    'controller': 'دراعة تحكم', 'ps_console': 'بلايستيشن',
    'pc_case': 'كيسة كمبيوتر',
    'washing_machine': 'غسالة', 'fridge': 'ثلاجة', 'refrigerator': 'ثلاجة',
    'cooker': 'بوتاجاز', 'stove': 'بوتاجاز',
    'microwave': 'ميكروويف', 'blender': 'خلاط',
    'ac_unit': 'تكييف', 'fan': 'مروحة',
    'heater': 'دفاية', 'water_heater': 'سخان مياه',
    'iron': 'مكواة',
    'vacuum_cleaner': 'مكنسة كهربائية', 'vacuum cleaner': 'مكنسة كهربائية',
    'water_filter': 'فلتر مياه',
    'gas_cylinder': 'أنبوبة غاز', 'gas_bottle': 'أنبوبة غاز',
    'freighter': 'ديب فريزر',
    'korda': 'خردة', 'scrap_metal': 'خردة معادن',
    'copper_wire': 'سلك نحاس', 'wire': 'سلك',
    'aluminum': 'ألومنيوم', 'equipment': 'معدات', 'mator': 'موتور',
    'car': 'سيارة',
    'building': 'مبنى',
    'book': 'كتاب',
  };

  /// Classify image by calling HF Space DIRECTLY (avoids Vercel 10s timeout).
  /// Falls back to the backend endpoint if HF Space is unreachable.
  static Future<Map<String, dynamic>> classifyImage(String filePath) async {
    try {
      debugPrint('[ClassifyService] Calling HF Space directly...');

      // ── Step 1: Upload the image to HF Space ──
      final uploadUrl = '$_hfSpaceUrl/gradio_api/upload';
      final imgBytes = await File(filePath).readAsBytes();
      final filename = filePath.split(Platform.pathSeparator).last;

      final uploadReq = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      uploadReq.files.add(http.MultipartFile.fromBytes(
        'files',
        imgBytes,
        filename: filename,
      ));

      final uploadResp = await uploadReq.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Upload to HF Space timed out'),
      );
      final uploadBody = await http.Response.fromStream(uploadResp);

      if (uploadResp.statusCode != 200) {
        debugPrint('[ClassifyService] HF Upload failed: ${uploadBody.body}');
        return _fallbackToBackend(filePath);
      }

      final uploadedFiles = jsonDecode(uploadBody.body);
      if (uploadedFiles is! List || uploadedFiles.isEmpty) {
        debugPrint('[ClassifyService] HF Upload returned empty');
        return _fallbackToBackend(filePath);
      }

      final uploadedPath = uploadedFiles[0];
      debugPrint('[ClassifyService] Uploaded to HF: $uploadedPath');

      // ── Step 2: Call /gradio_api/call/predict ──
      final predictUrl = '$_hfSpaceUrl/gradio_api/call/predict';
      final predictResp = await http.post(
        Uri.parse(predictUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': [
            {'path': uploadedPath, 'meta': {'_type': 'gradio.FileData'}}
          ]
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Predict call timed out'),
      );

      if (predictResp.statusCode != 200) {
        debugPrint('[ClassifyService] HF Predict failed: ${predictResp.body}');
        return _fallbackToBackend(filePath);
      }

      final eventIdJson = jsonDecode(predictResp.body);
      final eventId = eventIdJson['event_id'];
      if (eventId == null) {
        debugPrint('[ClassifyService] No event_id returned');
        return _fallbackToBackend(filePath);
      }

      debugPrint('[ClassifyService] Got event_id: $eventId');

      // ── Step 3: Get SSE result ──
      final resultUrl = '$_hfSpaceUrl/gradio_api/call/predict/$eventId';
      final resultResp = await http.get(Uri.parse(resultUrl)).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Result fetch timed out'),
      );

      if (resultResp.statusCode != 200) {
        debugPrint('[ClassifyService] HF Result failed: ${resultResp.body}');
        return _fallbackToBackend(filePath);
      }

      // Parse SSE response
      Map<String, dynamic>? resultData;
      for (final line in resultResp.body.split('\n')) {
        if (line.startsWith('data:')) {
          final dataStr = line.substring(5).trim();
          try {
            final parsed = jsonDecode(dataStr);
            if (parsed is List) {
              resultData = {'data': parsed};
            } else if (parsed is Map) {
              resultData = Map<String, dynamic>.from(parsed);
            }
          } catch (_) {}
        }
      }

      if (resultData == null) {
        debugPrint('[ClassifyService] No valid SSE data');
        return _fallbackToBackend(filePath);
      }

      debugPrint('[ClassifyService] HF raw result: $resultData');

      // ── Step 4: Extract class name ──
      final data = resultData['data'] ?? resultData;
      String bestClass = 'other';

      if (data is List) {
        if (data.length >= 2 && data[1] is String) {
          bestClass = data[1].toString().trim();
        } else if (data.isNotEmpty && data[0] is String) {
          bestClass = data[0].toString().trim();
        }
      }

      debugPrint('[ClassifyService] Detected class: $bestClass');

      // ── Step 5: Map to category ──
      final categoryId = _categoryMap[bestClass]
          ?? _categoryMap[bestClass.toLowerCase()]
          ?? 'other';
      final classLabelAr = _classLabelsAr[bestClass]
          ?? _classLabelsAr[bestClass.toLowerCase()]
          ?? bestClass;

      return {
        'category': categoryId,
        'detected_class': bestClass,
        'detected_class_ar': classLabelAr,
        'confidence': 0.95,
      };

    } catch (e) {
      debugPrint('[ClassifyService] Direct HF call failed: $e');
      return _fallbackToBackend(filePath);
    }
  }

  /// Fallback: try the backend endpoint (works when running locally)
  static Future<Map<String, dynamic>> _fallbackToBackend(String filePath) async {
    try {
      debugPrint('[ClassifyService] Falling back to backend endpoint...');
      final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.classifyImage);
      final request = http.MultipartRequest('POST', uri);

      final token = await SecureStorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('[ClassifyService] Backend status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (e) {
      debugPrint('[ClassifyService] Backend fallback also failed: $e');
    }
    return {'category': 'other'};
  }
}
