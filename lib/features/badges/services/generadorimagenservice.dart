

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class GeneradorImagenService {
  static const String _baseUrl = 'http://192.168.3.8:1234';
  static const Duration _intervaloConsulta = Duration(seconds: 3);
  static const Duration _tiempoMaximo = Duration(minutes: 15);

  final http.Client _client;

  GeneradorImagenService({http.Client? client})
      : _client = client ?? http.Client();

  Future<Uint8List> generarImagen({
    required String descripcion,
  }) async {
    if (descripcion.trim().isEmpty) {
      throw Exception('Ingresá una descripción para la imagen');
    }

    try {
      // 1. Enviar solicitud de generación.
      final respuesta = await _client.post(
        Uri.parse('$_baseUrl/sdcpp/v1/img_gen'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auto_resize_ref_image': true,
          'batch_count': 1,
          'cache_mode': 'disabled',
          'clip_skip': -1,
          'control_image': null,
          'control_strength': 0.9,
          'height': 512,
          'increase_ref_index': false,
          'init_image': null,
          'ip_adapter_image': null,
          'ip_adapter_strength': 1,
          'lora': [],
          'mask_image': null,
          'negative_prompt': '',
          'output_compression': 100,
          'output_format': 'png',
          'preview': 'none',
          'prompt': descripcion.trim(),
          'ref_images': [],
          'sample_params': {
            'sample_steps': 20,
            'shifted_timestep': 0,
            'guidance': {
              'txt_cfg': 7,
              'distilled_guidance': 3.5,
              'slg': {
                'layers': [7, 8, 9],
                'layer_start': 0.01,
                'layer_end': 0.2,
                'scale': 0,
              },
            },
          },
          'seed': -1,
          'vae_tiling_params': {
            'enabled': false,
            'tile_size_w': 0,
            'tile_size_h': 0,
            'target_overlap': 0.5,
            'rel_size_w': 0,
            'rel_size_h': 0,
          },
          'width': 512,
        }),
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode != 202) {
        throw Exception(
          'Error al iniciar la generación: ${respuesta.body}',
        );
      }

      final datos = jsonDecode(respuesta.body);

      if (datos is! Map || datos['id'] == null) {
        throw Exception('El servidor no devolvió el ID del trabajo');
      }

      final String idTrabajo = datos['id'].toString();

      // 2. Consultar el trabajo hasta que termine.
      final cronometro = Stopwatch()..start();

      while (cronometro.elapsed < _tiempoMaximo) {
        await Future.delayed(_intervaloConsulta);

        final consulta = await _client.get(
          Uri.parse('$_baseUrl/sdcpp/v1/jobs/$idTrabajo'),
        ).timeout(const Duration(seconds: 30));

        if (consulta.statusCode != 200) {
          throw Exception('Error al consultar el trabajo');
        }

        final estado = jsonDecode(consulta.body);

        if (estado is! Map) {
          throw Exception('Respuesta inválida del servidor');
        }

        final String status = estado['status']?.toString() ?? '';

        if (status == 'failed') {
          throw Exception(
            estado['error']?.toString() ?? 'Falló la generación',
          );
        }

        if (status == 'completed') {
          final resultado = estado['result'];

          if (resultado is! Map ||
              resultado['images'] is! List ||
              (resultado['images'] as List).isEmpty) {
            throw Exception('El servidor no devolvió imágenes');
          }

          final imagen = resultado['images'][0];

          if (imagen is! Map || imagen['b64_json'] == null) {
            throw Exception('No se encontró la imagen Base64');
          }

          return Uint8List.fromList(
            base64Decode(imagen['b64_json'].toString()),
          );
        }
      }

      throw Exception('La generación superó el tiempo máximo de espera');
    } on TimeoutException {
      throw Exception('Se agotó el tiempo de espera del servidor');
    } on http.ClientException catch (e) {
      throw Exception('No se pudo conectar con Stable Diffusion: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
