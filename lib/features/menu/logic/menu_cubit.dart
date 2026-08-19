import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/menu_repository.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final MenuRepository repository;
  List<dynamic> _cachedMenus = [];

  MenuCubit(this.repository) : super(MenuInitial());

  // Hapus semua parameter token
  Future<void> fetchMenus() async {
    emit(MenuLoading());
    try {
      _cachedMenus = await repository.getMenus();
      emit(MenuLoaded(_cachedMenus));
    } catch (e) {
      emit(MenuError(_cleanError(e)));
    }
  }

  Future<void> createMenu(Map<String, dynamic> data) async {
    emit(MenuLoading());
    try {
      await repository.createMenu(data);
      emit(MenuActionSuccess("Menu berhasil ditambahkan!"));
      fetchMenus();
    } catch (e) {
      emit(MenuError(_cleanError(e)));
      emit(MenuLoaded(_cachedMenus));
    }
  }

  Future<void> updateMenu(String id, Map<String, dynamic> data) async {
    emit(MenuLoading());
    try {
      await repository.updateMenu(id, data);
      emit(MenuActionSuccess("Menu berhasil diubah!"));
      fetchMenus();
    } catch (e) {
      emit(MenuError(_cleanError(e)));
      emit(MenuLoaded(_cachedMenus));
    }
  }

  Future<void> deleteMenu(String id) async {
    try {
      await repository.deleteMenu(id);
      emit(MenuActionSuccess("Menu dihapus!"));
      fetchMenus();
    } catch (e) {
      emit(MenuError(_cleanError(e)));
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      await repository.toggleMenuStatus(id);
      emit(MenuActionSuccess("Status menu diubah!"));
      fetchMenus();
    } catch (e) {
      emit(MenuError(_cleanError(e)));
    }
  }

  String _cleanError(Object error) => error.toString().replaceAll('Exception: ', '');
}