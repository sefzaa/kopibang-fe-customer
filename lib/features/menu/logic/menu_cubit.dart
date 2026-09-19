import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/menu_repository.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final MenuRepository repository;

  MenuCubit({required this.repository}) : super(MenuInitial());

  Future<void> fetchMenus() async {
    emit(MenuLoading());
    try {
      final menus = await repository.getMenus();
      emit(MenuLoaded(menus));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}