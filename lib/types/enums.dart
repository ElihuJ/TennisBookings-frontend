import '../helpers/index.dart';

enum Environment { dev, prod, staging }

enum MessageType { success, error, warning, info }

enum ListOrder implements IsEnum {
  asc,
  desc;

  @override
  String get name {
    switch (this) {
      case ListOrder.asc:
        return 'Ascending';
      case ListOrder.desc:
        return 'Descending';
      default:
        return '';
    }
  }

  @override
  String get locale {
    switch (this) {
      case ListOrder.asc:
        return 'filters_ascending';
      case ListOrder.desc:
        return 'filters_descending';
    }
  }
}

enum SortOptions implements IsEnum {
  lastUse,
  totalRecipes,
  averageScore,
  filterName;

  @override
  String get name {
    switch (this) {
      case SortOptions.filterName:
        return 'Name';
      case SortOptions.lastUse:
        return 'Last use';
      case SortOptions.totalRecipes:
        return 'Total recipes';
      case SortOptions.averageScore:
        return 'Average score';
    }
  }

  @override
  String get locale {
    switch (this) {
      case SortOptions.filterName:
        return 'filters_name';
      case SortOptions.lastUse:
        return 'filters_last_used';
      case SortOptions.totalRecipes:
        return 'filters_total_recipes';
      case SortOptions.averageScore:
        return 'filters_average_score';
    }
  }
}

enum BeanRoast implements IsEnum {
  light,
  medium,
  mediumDark,
  dark;

  static BeanRoast? fromString(String? roast) {
    switch (roast) {
      case 'light':
        return BeanRoast.light;
      case 'medium':
        return BeanRoast.medium;
      case 'medium_dark':
        return BeanRoast.mediumDark;
      case 'dark':
        return BeanRoast.dark;
      default:
        roast?.tbLogger('WRONG ROAST TYPE', DebugLevel.warning);
        return null;
    }
  }

  @override
  String get name {
    switch (this) {
      case BeanRoast.light:
        return 'light';
      case BeanRoast.medium:
        return 'medium';
      case BeanRoast.mediumDark:
        return 'medium_dark';
      case BeanRoast.dark:
        return 'dark';
    }
  }

  @override
  String get locale {
    switch (this) {
      case BeanRoast.light:
        return 'enum_strings_light';
      case BeanRoast.medium:
        return 'enum_strings_medium';
      case BeanRoast.mediumDark:
        return 'enum_strings_medium_dark';
      case BeanRoast.dark:
        return 'enum_strings_dark';
    }
  }

  @override
  String toString() => name;
}

enum BeanType implements IsEnum {
  arabica,
  robusta,
  mix;

  static BeanType? fromString(String? roast) {
    switch (roast) {
      case 'arabica':
        return BeanType.arabica;
      case 'robusta':
        return BeanType.robusta;
      case 'mix':
        return BeanType.mix;
      default:
        roast?.tbLogger('WRONG BEAN TYPE', DebugLevel.warning);
        return null;
    }
  }

  @override
  String get name {
    switch (this) {
      case BeanType.arabica:
        return 'arabica';
      case BeanType.robusta:
        return 'robusta';
      case BeanType.mix:
        return 'mix';
    }
  }

  @override
  String get locale {
    switch (this) {
      case BeanType.arabica:
        return 'enum_strings_arabica';
      case BeanType.robusta:
        return 'enum_strings_robusta';
      case BeanType.mix:
        return 'enum_strings_mix';
    }
  }

  @override
  String toString() => name;
}
