import 'home_datasource.dart';
import '../models/negocio_preview_model.dart';
import '../models/categoria_negocio_model.dart';
import '../models/promocion_model.dart';
import '../models/producto_popular_model.dart';

class MockHomeDataSource implements HomeDataSource {
  @override
  Future<List<NegocioPreviewModel>> getNegociosCercanos() async => const [
        NegocioPreviewModel(
          id: '1',
          nombre: 'La Panadería Elena',
          categoria: 'Panadería',
          distanciaKm: 0.3,
          abierto: true,
          verificado: true,
          calificacion: 4.9,
        ),
        NegocioPreviewModel(
          id: '2',
          nombre: 'Agro San Cristóbal',
          categoria: 'Agropecuario',
          distanciaKm: 0.8,
          abierto: false,
          calificacion: 4.5,
        ),
        NegocioPreviewModel(
          id: '3',
          nombre: 'Farmacia Vida',
          categoria: 'Farmacia',
          distanciaKm: 1.2,
          abierto: true,
          verificado: true,
          calificacion: 4.8,
        ),
        NegocioPreviewModel(
          id: '4',
          nombre: 'Cafetería El Patio',
          categoria: 'Cafetería',
          distanciaKm: 1.5,
          abierto: true,
          calificacion: 4.7,
        ),
        NegocioPreviewModel(
          id: '5',
          nombre: 'Tienda La Esquina',
          categoria: 'Tienda',
          distanciaKm: 2.0,
          abierto: true,
          calificacion: 4.3,
        ),
        NegocioPreviewModel(
          id: '6',
          nombre: 'Ferretería Central',
          categoria: 'Ferretería',
          distanciaKm: 2.3,
          abierto: false,
          calificacion: 4.6,
        ),
      ];

  @override
  Future<List<CategoriaNegocioModel>> getCategorias() async => const [
        CategoriaNegocioModel(id: 'cat-1', nombre: 'Cafetería', icono: 'coffee'),
        CategoriaNegocioModel(id: 'cat-2', nombre: 'Agropecuario', icono: 'grass'),
        CategoriaNegocioModel(
            id: 'cat-3', nombre: 'Farmacia', icono: 'local_pharmacy'),
        CategoriaNegocioModel(
            id: 'cat-4', nombre: 'Panadería', icono: 'bakery_dining'),
        CategoriaNegocioModel(id: 'cat-5', nombre: 'Tienda', icono: 'store'),
        CategoriaNegocioModel(
            id: 'cat-6', nombre: 'Salud', icono: 'health_and_safety'),
        CategoriaNegocioModel(
            id: 'cat-7', nombre: 'Ferretería', icono: 'hardware'),
        CategoriaNegocioModel(
            id: 'cat-8', nombre: 'Restaurante', icono: 'restaurant'),
      ];

  @override
  Future<List<PromocionModel>> getPromociones() async => const [
        PromocionModel(
          id: 'promo-1',
          titulo: 'Ofertas de temporada',
          nombreNegocio: 'La Panadería Elena',
          negocioId: '1',
        ),
        PromocionModel(
          id: 'promo-2',
          titulo: 'Productos frescos hoy',
          nombreNegocio: 'Agro San Cristóbal',
          negocioId: '2',
        ),
        PromocionModel(
          id: 'promo-3',
          titulo: 'Medicamentos disponibles',
          nombreNegocio: 'Farmacia Vida',
          negocioId: '3',
        ),
      ];

  @override
  Future<List<ProductoPopularModel>> getProductosPopulares() async => const [
        ProductoPopularModel(
          id: 'prod-1',
          nombre: 'Huevos',
          precio: 350,
          unidad: 'cajita',
          negocioNombre: 'Agro San Cristóbal',
          negocioId: '2',
          imagenUrl:
              'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=300&h=300&fit=crop&auto=format',
        ),
        ProductoPopularModel(
          id: 'prod-2',
          nombre: 'Pan Criollo',
          precio: 25,
          unidad: 'unidad',
          negocioNombre: 'La Panadería Elena',
          negocioId: '1',
          imagenUrl:
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&h=300&fit=crop&auto=format',
        ),
        ProductoPopularModel(
          id: 'prod-3',
          nombre: 'Aceite Vegetal',
          precio: 620,
          unidad: 'botella',
          negocioNombre: 'Tienda La Esquina',
          negocioId: '5',
          imagenUrl:
              'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=300&h=300&fit=crop&auto=format',
        ),
        ProductoPopularModel(
          id: 'prod-4',
          nombre: 'Pollo',
          precio: 890,
          unidad: 'libra',
          negocioNombre: 'Agro San Cristóbal',
          negocioId: '2',
          imagenUrl:
              'https://images.unsplash.com/photo-1587593810167-a84920ea0781?w=300&h=300&fit=crop&auto=format',
        ),
        ProductoPopularModel(
          id: 'prod-5',
          nombre: 'Arroz',
          precio: 180,
          unidad: 'libra',
          negocioNombre: 'Tienda La Esquina',
          negocioId: '5',
          imagenUrl:
              'https://images.unsplash.com/photo-1536304993881-ff86e0c9ef1d?w=300&h=300&fit=crop&auto=format',
        ),
        ProductoPopularModel(
          id: 'prod-6',
          nombre: 'Aspirina 500mg',
          precio: 45,
          unidad: 'tableta',
          negocioNombre: 'Farmacia Vida',
          negocioId: '3',
          imagenUrl:
              'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=300&h=300&fit=crop&auto=format',
        ),
      ];
}
